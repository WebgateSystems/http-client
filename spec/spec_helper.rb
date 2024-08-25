# encoding: utf-8
# frozen_string_literal: true
require File.expand_path('../environment', __FILE__)

unless defined?(HTTP_CLIENT_ROOT)
  $stderr.puts("Running Specs under Ruby Version #{RUBY_VERSION}")
  HTTP_CLIENT_ROOT = File.join(File.dirname(__FILE__), '../')
end

unless defined?(SPEC_ROOT)
  SPEC_ROOT = File.join(File.dirname(__FILE__))
end

require 'rspec'
require 'active_support'
require 'active_support/core_ext'
require 'faraday'
require 'webmock/rspec'

$stderr.puts("Running Specs for Http Client Version #{WS::HttpClient::VERSION::STRING}")

# NOTE: We set the KCODE manually here in 1.8.X because upgrading to rspec-2.8.0 caused it
#       to default to "NONE" (Why!?).
$KCODE='UTF8' if RUBY_VERSION < '1.9'
