require 'active_record_stats/rack_middleware'
require 'statsd/instrument/matchers'
require 'rack/test'

RSpec.describe ActiveRecordStats::RackMiddleware do
  include Rack::Test::Methods
  include StatsD::Instrument::Matchers

  let(:controller_name) { 'v1/query_issuer' }
  let(:action_name)     { 'index' }

  let(:handler) do
    lambda do |env|
      if env['PATH_INFO'] == '/'
        # Pretend like we're in a request that Rails actually routed:
        env[described_class::ENV_KEY] = {
          'controller' => controller_name,
          'action' => action_name
        }
      else
        # Pretend that ActionDispatch failed to populate `controller`
        # and `action` for whatever reason:
        env[described_class::ENV_KEY] = {}
      end

      ActiveRecord::Base.transaction do # BEGIN
        # SELECT ...
        Widget.first

        # INSERT ...
        Widget.create(name: 'foo')

        # UPDATE ...
        Widget.update_all(name: 'bar')

        # SELECT + DELETE ...
        Widget.first.destroy

        # Manual query with leading comment and whitespace
        ActiveRecord::Base.connection.execute <<-SQL

        -- foo!
          SELECT * FROM widgets;

        SQL

        # CTEs are emitted as `WITH` queries, because we can't afford
        # to do real SQL parsing
        ActiveRecord::Base.connection.execute <<-SQL
        WITH cte AS (SELECT 'foo') SELECT * FROM cte
        SQL
      end # COMMIT

      [200, {}, ['OK']]
    end
  end

  let(:app) do
    ActiveRecordStats::RackMiddleware.new(handler)
  end

  %w[SELECT INSERT UPDATE DELETE BEGIN COMMIT].each do |type|
    it "emits gauges with the total number of `#{type}` statements" do
      expect { get '/' }.to trigger_statsd_gauge(
        "db.web.v1__query_issuer.index.#{type}",
        times: 1
      )
    end
  end

  it 'ignores request without `controller` and `action` available' do
    expect(StatsD).not_to receive(:gauge)
    expect(StatsD).not_to receive(:measure)
    get '/avoid-rails'
  end

  # The `process_action.action_controller` notification isn't actually being
  # received, but we still emit a zero. Which is fair enough, IMO.
  it 'emits a timer with the total time, in ms, spent in ActiveRecord' do
    expect { get '/' }.to trigger_statsd_measure(
      "db.web.v1__query_issuer.index.runtime",
      times: 1
    )
  end
end
