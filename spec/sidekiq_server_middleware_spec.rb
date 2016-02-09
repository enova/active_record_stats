require 'active_record_stats/sidekiq_server_middleware'
require 'sidekiq'

#REDIS_URL = ENV['REDIS_URL'] || 'redis://localhost/15'

#Sidekiq.configure_client do |config|
  #config.redis = { url: REDIS_URL, namespace: 'ar_stats_test' }
#end

RSpec.describe ActiveRecordStats::SidekiqServerMiddleware do
  include StatsD::Instrument::Matchers

  let(:handler) do
    described_class.new
  end

  module ARS
    class SidekiqJob
      include Sidekiq::Worker
    end
  end

  def perform
    handler.call(ARS::SidekiqJob.new, {}, 'default') do
      IssueSomeQueries.call
    end
  end

  %w[SELECT INSERT UPDATE DELETE BEGIN COMMIT].each do |type|
    it "emits gauges with the total number of `#{type}` statements" do
      expect { perform }.to trigger_statsd_gauge(
        "db.job.ars__sidekiq_job.#{type}",
        times: 1
      )
    end
  end
end
