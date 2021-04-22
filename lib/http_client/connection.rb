# frozen_string_literal: true

module WS
  module HttpClient
    class Connection
      AVAILABLE_HTTP_METHODS = %i[connect delete get head options patch post put trace].freeze

      def initialize(base_url, connection_options = {})
        @base_url = base_url
        @connection = create_connection(connection_options)
        @logger = defined?(::Rails) ? Rails.logger : Logger.new
        @settings = defined?(::Settings) ? Settings : connection_settings
      end

      AVAILABLE_HTTP_METHODS.each do |http_method|
        define_method(http_method) do |endpoint, body = {}, headers = {}, options = {}|
          args = [build_url(endpoint), body, headers]

          if http_method == :options
            faraday_method = 'run_request'
            args.unshift(:options)
          else
            faraday_method = http_method
          end

          @response = @connection.public_send(faraday_method, *args) do |request|
            request.options.timeout = options[:timeout_read] || @settings.faraday.dig(:timeout, :read)
            request.options.open_timeout = options[:timeout_open] || @settings.faraday.dig(:timeout, :read)
          end

          log_and_raise_if_necessary(options[:expected_statuses])

          Response.new(body: @response.body, status: @response.status, headers: @response.headers)
        end
      end

      private

      def create_connection(options)
        faraday_options = {
          headers: options[:headers] || {},
          ssl: {
            verify: options.dig(:ssl, :verify),
            ca_file: options.dig(:ssl, :ca_file)
          }
        }
        content_type = faraday_options[:headers]['Content-Type']
        request_type = content_type && content_type.include?('urlencoded') ? :url_encoded : :json # json - default

        Faraday.new(faraday_options) do |builder|
          builder.use Faraday::Response::Logger, @logger
          builder.request request_type
          builder.response :logger, @logger
          builder.response :json, content_type: /\bjson$/
          builder.adapter :net_http
        end
      end

      def build_url(endpoint)
        uri = URI(@base_url)
        uri.path += endpoint
        uri.to_s
      end

      def log_and_raise_if_necessary(expected_statuses)
        return if permitted_response?(expected_statuses)

        message = "Unexpected HTTP response #{@response.status} '#{@response.body}'"
        @logger.error(message)
        raise UnexpectedStatusError, message
      end

      def permitted_response?(expected_statuses)
        expected_statuses.nil? ||
          [expected_statuses].flatten.any? { |permitted| permitted === @response.status }
      end

      def connection_settings
        OpenStruct.new(
          faraday: {
            timeout: {
              read: 5,
              open: 7,
            }
          }
        )
      end
    end
  end
end
