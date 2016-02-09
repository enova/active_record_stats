require 'active_record_stats/sidekiq_server_middleware'
require_relative 'shared_examples'

RSpec.describe ActiveRecordStats::SidekiqServerMiddleware do
  let(:handler) do
    described_class.new
  end

  module ARS
    class SidekiqJob
    end
  end

  def perform
    handler.call(ARS::SidekiqJob.new, {}, 'default') do
      IssueSomeQueries.call
    end
  end

  include_examples 'emits gauges', 'db.job.ars__sidekiq_job'
end
