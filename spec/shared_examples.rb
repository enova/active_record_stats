require 'statsd/instrument/matchers'

RSpec.shared_examples 'emits gauges' do |metric_prefix|
  include StatsD::Instrument::Matchers

  %w[SELECT INSERT UPDATE DELETE BEGIN COMMIT].each do |type|
    it "emits a gauge with the total number of #{type} statements" do
      expect { perform }.to trigger_statsd_gauge(
        "#{metric_prefix}.#{type}",
        times: 1
      )
    end
  end
end
