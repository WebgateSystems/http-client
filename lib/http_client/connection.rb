# frozen_string_literal: true

module WS
  module HttpClient
    class Connection
      AVAILABLE_HTTP_METHODS = %i[connect delete get head options patch post put trace].freeze
      DEFAULT_READ_TIMEOUT = 5
      DEFAULT_OPEN_TIMEOUT = 7
      FallbackSettings = Struct.new(:faraday, keyword_init: true)

      def initialize(base_url, connection_options = {})
        @base_url = base_url
        @logger = defined?(::Rails) ? Rails.logger : Logger.new
        @settings = defined?(::Settings) ? Settings : connection_settings
        @connection = create_connection(connection_options)
      end

      AVAILABLE_HTTP_METHODS.each do |http_method|
        define_method(http_method) do |endpoint, body = {}, headers = {}, options = {}|
          perform(http_method, endpoint, body, headers, options)
        end
      end

      private

      def perform(http_method, endpoint, body, headers, options)
        faraday_response = dispatch(http_method, endpoint, body, headers, options)
        response = build_response(faraday_response)
        log_and_raise_if_necessary(response, options[:expected_statuses])
        response
      rescue Faraday::TimeoutError => e
        raise TimeoutError, e.message
      rescue Faraday::ConnectionFailed => e
        raise ConnectionError, e.message
      end

      def dispatch(http_method, endpoint, body, headers, options)
        method_name, args = faraday_invocation(http_method, endpoint, body, headers)
        @connection.public_send(method_name, *args) { |request| assign_timeouts(request, options) }
      end

      def faraday_invocation(http_method, endpoint, body, headers)
        args = [build_url(endpoint), body, headers]
        return [:run_request, [:options, *args]] if http_method == :options

        [http_method, args]
      end

      def assign_timeouts(request, options)
        request.options.timeout = options[:timeout_read] || read_timeout
        request.options.open_timeout = options[:timeout_open] || open_timeout
      end

      def build_response(faraday_response)
        Response.new(
          body: faraday_response.body,
          status: faraday_response.status,
          headers: faraday_response.headers
        )
      end

      def create_connection(options)
        FaradayBuilder.new(@logger, options).connection
      end

      def build_url(endpoint)
        Url.join(@base_url, endpoint)
      end

      def log_and_raise_if_necessary(response, expected_statuses)
        return if permitted_response?(response, expected_statuses)

        @logger.error("Unexpected HTTP status: #{response.status}")
        raise UnexpectedStatusError, response
      end

      def permitted_response?(response, expected_statuses)
        expected_statuses.nil? || matches_status?(expected_statuses, response.status)
      end

      def matches_status?(expected_statuses, status)
        [expected_statuses].flatten.any? { |permitted| status_allowed?(permitted, status) }
      end

      def status_allowed?(permitted, status)
        return permitted.cover?(status) if permitted.is_a?(Range)

        permitted == status
      end

      def read_timeout
        @settings.faraday.dig(:timeout, :read) || DEFAULT_READ_TIMEOUT
      end

      def open_timeout
        @settings.faraday.dig(:timeout, :open) || DEFAULT_OPEN_TIMEOUT
      end

      def connection_settings
        FallbackSettings.new(
          faraday: {
            timeout: {
              read: DEFAULT_READ_TIMEOUT,
              open: DEFAULT_OPEN_TIMEOUT
            }
          }
        )
      end
    end
  end
end
