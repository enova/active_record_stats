$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'

require 'active_record_stats'
require 'statsd/instrument/matchers'
require_relative 'shared_examples'

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |expect|
    expect.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end

  config.include StatsD::Instrument::Matchers
end

# Set up a world in which ActiveRecord more or less works.
ActiveRecord::Base.establish_connection(
  adapter:  'postgresql',
  encoding: 'unicode',
  database: 'active_record_stats_test',
  host:     'localhost'
)

ActiveRecord::Base.connection.execute <<-SQL
CREATE TABLE IF NOT EXISTS widgets (id SERIAL PRIMARY KEY, name TEXT NOT NULL);
SQL

class Widget < ActiveRecord::Base
end

# The common set of queries that we execute in tests.
IssueSomeQueries = lambda do
  ActiveRecord::Base.transaction do # BEGIN
    # SELECT ...
    Widget.first

    # INSERT ...
    Widget.create(name: 'foo')

    # UPDATE ...
    Widget.update_all(name: 'bar')

    # SELECT + DELETE ...
    Widget.first.destroy

    # Manual query with leading comment and whitespace
    ActiveRecord::Base.connection.execute <<-SQL

    -- foo!
      SELECT * FROM widgets;

    SQL

    # CTEs are emitted as `WITH` queries, because we can't afford
    # to do real SQL parsing
    ActiveRecord::Base.connection.execute <<-SQL
    WITH cte AS (SELECT 'foo') SELECT * FROM cte
    SQL
  end # COMMIT
end
