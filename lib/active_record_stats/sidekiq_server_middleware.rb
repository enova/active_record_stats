require 'active_record_stats'

module ActiveRecordStats
  class SidekiqServerMiddleware
    def call(worker, job, queue)
      totals = {}

      gather_sql = ->(_name, _started_at, _finished_at, _unique_id, payload) {
        return if payload[:name] == 'SCHEMA' || payload[:sql].blank?
        return unless type = ActiveRecordStats.statement_type(payload[:sql])
        totals[type] ||= 0
        totals[type] += 1
      }

      sub = ActiveSupport::Notifications.subscribe('sql.active_record', &gather_sql)
      yield

    ensure
      emit(worker.class.to_s, totals)
      ActiveSupport::Notifications.unsubscribe(sub)
    end

    private

    def emit(worker_name, totals)
      job = worker_name.underscore.gsub('/', '__')
      totals.each do |verb, count|
        StatsD.gauge "db.job.#{job}.#{verb}", count
      end
    end
  end
end
