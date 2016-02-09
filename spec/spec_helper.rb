$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'active_record_stats'

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
