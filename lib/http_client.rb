# frozen_string_literal: true

module WS
  module HttpClient
    require 'faraday'
    require 'uri'
    require 'http_client/version'

    require 'http_client/logger'
    require 'http_client/errors'
    require 'http_client/response'
    require 'http_client/url'
    require 'http_client/faraday_builder'
    require 'http_client/connection'
  end
end
