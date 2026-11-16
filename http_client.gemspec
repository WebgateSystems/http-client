# frozen_string_literal: true

require './lib/http_client/version'

Gem::Specification.new do |s|
  s.name        = 'http_client'
  s.version     = WS::HttpClient::VERSION::STRING
  s.author      = 'Jerzy Sladkowski'
  s.email       = 'sladkowski@webgate.pro'
  s.homepage    = 'https://github.com/WebgateSystems/http-client'
  s.summary     = 'Thin Faraday wrapper for HTTP requests, responses, and errors.'
  s.description = 'Joins a base URL with a path, returns one response object, and raises its own ' \
                  'errors for timeouts, connection failures, and unexpected statuses. ' \
                  'Requires Ruby 3.3 or newer and Faraday 2.'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 3.3.0'
  # Oldest Ruby the locked gems install on. Keep .gitlab-ci.yml and .github/workflows/ci.yml in step.
  s.metadata['supported_ruby_versions'] = '3.3, 3.4, 4.0'

  s.metadata['homepage_uri'] = s.homepage
  s.metadata['source_code_uri'] = 'https://github.com/WebgateSystems/http-client'
  s.metadata['changelog_uri'] = 'https://github.com/WebgateSystems/http-client/blob/main/CHANGELOG.md'

  s.extra_rdoc_files = %w[README.md CHANGELOG.md]

  s.add_dependency 'faraday', '>= 2.14.3', '< 3'

  s.files = %w[README.md CHANGELOG.md LICENSE] + Dir.glob('lib/**/*')
end
