require "active_record_stats/version"
require "active_record"

module ActiveRecordStats
  def self.statement_type(sql)
    return if sql.nil?

    cleaned = sql.gsub(/^\s*(?:--.*)?$/, '').strip
    return if cleaned.empty?

    type = cleaned.split(' ', 2).first
    type.try(:upcase)
  end
end
