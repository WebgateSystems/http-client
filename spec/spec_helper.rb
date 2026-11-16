# frozen_string_literal: true

require 'simplecov'
SimpleCov.start
SimpleCov.minimum_coverage 100

require File.expand_path('environment', __dir__)

unless defined?(HTTP_CLIENT_ROOT)
  warn("Running Specs under Ruby Version #{RUBY_VERSION}")
  HTTP_CLIENT_ROOT = File.join(File.dirname(__FILE__), '../')
end

SPEC_ROOT = File.join(File.dirname(__FILE__)) unless defined?(SPEC_ROOT)

require 'rspec'
require 'active_support'
require 'active_support/core_ext'
require 'faraday'
require 'webmock/rspec'

warn("Running Specs for Http Client Version #{WS::HttpClient::VERSION::STRING}")
