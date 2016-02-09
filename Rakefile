require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :db do
  desc "Use psql's `createdb` to create the test database"
  task :create do
    sh "createdb active_record_stats_test"
  end

  desc "Use psql's `dropdb` to drop the test database"
  task :drop do
    sh "dropdb active_record_stats_test"
  end

  desc "db:{drop,create}"
  task reset: %w[db:drop db:create]
end
