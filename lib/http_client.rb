# encoding: utf-8
# frozen_string_literal: true
module WS # :doc:
  module HttpClient
    require 'faraday'
    require 'http_client/version'

    require 'http_client/connection'
    require 'http_client/logger'
    require 'http_client/response'
    require 'http_client/unexpected_status_error'
  end
end