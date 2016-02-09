# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record_stats/version'

Gem::Specification.new do |spec|
  spec.name          = "active_record_stats"
  spec.version       = ActiveRecordStats::VERSION
  spec.authors       = ["Kyle Hargraves"]
  spec.email         = ["khargraves@enova.com"]

  spec.summary       = %q{Emit ActiveRecord query counts and runtime to StatsD}
  spec.description   = %q{ActiveRecord instrumentation for Rails, Resque and Sidekiq}
  spec.homepage      = "https://git.enova.com/gems/active_record_stats"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'activerecord', '~> 4.0'
  spec.add_runtime_dependency 'statsd-instrument', '~> 2.0', '>= 2.0.4'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'pry', '~> 0.10'

  spec.add_development_dependency 'pg', '~> 0.18'
  spec.add_development_dependency 'actionpack', '~> 4.0'
  spec.add_development_dependency 'rack-test', '~> 0.6'
end
