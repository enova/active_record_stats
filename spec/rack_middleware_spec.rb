require 'active_record_stats/rack_middleware'
require 'rack/test'

RSpec.describe ActiveRecordStats::RackMiddleware do
  include Rack::Test::Methods

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

      IssueSomeQueries.call

      [200, {}, ['OK']]
    end
  end

  let(:app) do
    ActiveRecordStats::RackMiddleware.new(handler)
  end

  def perform
    get '/'
  end

  include_examples 'emits gauges', 'db.web.v1__query_issuer.index'

  it 'ignores request without `controller` and `action` available' do
    expect(StatsD).not_to receive(:gauge)
    expect(StatsD).not_to receive(:measure)
    get '/avoid-rails'
  end

  # The `process_action.action_controller` notification isn't actually being
  # received, but we still emit a zero. Which is fair enough, IMO.
  it 'emits a timer with the total time, in ms, spent in ActiveRecord' do
    expect { perform }.to trigger_statsd_measure(
      "db.web.v1__query_issuer.index.runtime",
      times: 1
    )
  end
end
