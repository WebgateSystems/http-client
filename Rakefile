require 'rubygems'
require 'bundler/setup'

require 'rake/testtask'
require 'rspec/core/rake_task'

desc "Build a gem file"
task :build do
  system "gem build http_client.gemspec"
end

task :default => :spec

RSpec::Core::RakeTask.new(:spec) do |t|
  t.ruby_opts = '-w'
  t.rspec_opts = %w(--backtrace --color)
end
