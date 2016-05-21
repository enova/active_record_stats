require 'active_record_stats/version'
require 'active_record'
require 'statsd-instrument'

module ActiveRecordStats
  STATEMENT_KEYS = %w[BEGIN COMMIT DELETE EXPLAIN INSERT
    RELEASE ROLLBACK SAVEPOINT SELECT UPDATE WITH].freeze

  def self.statement_type(sql)
    return if sql.nil?

    cleaned = sql.gsub(/^\s*(?:--.*)?$/, '').strip
    return if cleaned.empty?

    type = cleaned.split(' ', 2).first
    type.try(:upcase)
  end

  def self.statement_hash
    hash = {}
    STATEMENT_KEYS.each { |k| hash[k] = 0 }
    hash
  end
end
