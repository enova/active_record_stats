require 'active_record_stats'

module ActiveRecordStats
  module ResquePlugin
    def around_perform_active_record_stats(*args, &block)
      totals = ActiveRecordStats.statement_hash

      gather_sql = ->(_name, _started_at, _finished_at, _unique_id, payload) {
        return if payload[:name] == 'SCHEMA' || payload[:sql].blank?
        return unless type = ActiveRecordStats.statement_type(payload[:sql])
        totals[type] ||= 0
        totals[type] += 1
      }

      sub = ActiveSupport::Notifications.subscribe('sql.active_record', &gather_sql)
      yield

    ensure
      ActiveSupport::Notifications.unsubscribe(sub)
      emit_active_record_stats(name, totals)
    end

    private

    def emit_active_record_stats(name, totals)
      job = name.underscore.gsub('/', '__')
      totals.each do |verb, count|
        StatsD.gauge "db.job.#{job}.#{verb}", count
      end
    end
  end
end
