require 'active_record_stats/resque_plugin'

RSpec.describe ActiveRecordStats::ResquePlugin do
  module ARS
    class ResqueJob
      extend ActiveRecordStats::ResquePlugin
    end
  end

  def perform
    ARS::ResqueJob.around_perform_active_record_stats do
      IssueSomeQueries.call
    end
  end

  include_examples 'emits gauges', 'db.job.ars__resque_job'
end
