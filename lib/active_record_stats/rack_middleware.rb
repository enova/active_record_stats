require 'active_record_stats'
require 'active_support/notifications'
require 'action_dispatch/http/parameters'

module ActiveRecordStats
  class RackMiddleware
    # The location in the Rack `env` where ActionDispatch stores its
    # `parameters` value. This _may_ change across Rails versions, but
    # I am not aware of any more reliable means of retrieving it.
    ENV_KEY = 'action_dispatch.request.parameters'.freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      totals  = {}
      db_time = 0

      gather_sql = ->(_name, _started_at, _finished_at, _unique_id, payload) {
        return if payload[:name] == 'SCHEMA' || payload[:sql].blank?
        return unless type = ActiveRecordStats.statement_type(payload[:sql])
        totals[type] ||= 0
        totals[type] += 1
      }

      gather_runtime = ->(_name, _started_at, _finished_at, _unique_id, payload) {
        db_time = payload[:db_runtime]
      }

      subs = [
        ActiveSupport::Notifications.subscribe('sql.active_record', &gather_sql),
        ActiveSupport::Notifications.subscribe('process_action.action_controller', &gather_runtime)
      ]

      @app.call(env)

    ensure
      request_params = env[ENV_KEY]
      if controller = request_params['controller']
        controller = controller.gsub('/', '__')
        action = request_params['action']
        emit(controller, action, db_time, totals)
      end

      subs.each do |sub|
        ActiveSupport::Notifications.unsubscribe(sub)
      end
    end

    private

    def emit(controller, action, db_time, totals)
      totals.each do |verb, count|
        StatsD.gauge "db.web.#{controller}.#{action}.#{verb}", count
      end

      StatsD.measure "db.web.#{controller}.#{action}.runtime", db_time
    end
  end
end
