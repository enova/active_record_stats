# ActiveRecordStats

Provides Rails, Resque, and Sidekiq integrations for emitting metrics
about ActiveRecord usage to StatsD using Shopify's [statsd-instrument][].

## Installation

As usual:

~~~ruby
gem 'active_record_stats', require: false
~~~

This library assumes that statsd has already been configured, and is
available via the `StatsD` constant.

## Usage

For Rails web request instrumentation, add the following to your
`config/application.rb`:

~~~ruby
require 'active_record_stats/middleware'

module YourApp
  class Application < Rails::Application
    config.middleware.use 'ActiveRecordStats::Middleware'
  end
end
~~~

For Resque job instrumentation, `extend` your job classes like so:

~~~ruby
require 'active_record_stats/resque'

class SomeJob
  extend ActiveRecordStats::Resque
end
~~~

For Sidekiq instrumentation, ....

~~~ruby
require 'active_record_stats/sidekiq'

class SomeJob
  include ActiveRecordStats::Sidekiq
end
~~~

## Metric names

Metrics will be with names in the following formats:

1. Gauge db.web._controller_._action_._statement_: the number of `statement` queries
   performed for a given controller action.
2. Timer db.web._controller_._action_.runtime: the total `db_runtime` cost of
   a given controller action, in milliseconds.
3. Gauge db.job._class_._statement_: the number of `statement` queries performed
   for a given job.

As Graphite metric names may not contain a `/` character, they are replaced with
two underscores (`__`). For sanity's sake, the same is done for `::` delimiters.

Example metrics that might be emitted:

* `db.web.v1__widgets.update.UPDATE:2|g`: two `UPDATE` statements were issued
   when processing `V1::WidgetsController#update`.
* `db.web.posts.create.runtime:123|g`: Rails reported the total time spent
   in ActiveRecord for the `PostsController#create` action as 123 ms.
* `db.job.cache__prime.SELECT:10|g`: ten `SELECT` statements were issued when
   processing the `Cache::Prime` job.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[statsd-instrument]: https://github.com/Shopify/statsd-instrument
