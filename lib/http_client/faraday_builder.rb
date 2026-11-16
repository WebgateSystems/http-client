# frozen_string_literal: true

module WS
  module HttpClient
    class FaradayBuilder
      def initialize(logger, options)
        @logger = logger
        @options = options
      end

      def connection
        Faraday.new(faraday_options) do |builder|
          builder.request request_encoding
          builder.response :json, content_type: /\bjson$/
          install_logger(builder)
          builder.adapter :net_http
        end
      end

      private

      def faraday_options
        {
          headers: @options[:headers] || {},
          ssl: {
            verify: @options.dig(:ssl, :verify),
            ca_file: @options.dig(:ssl, :ca_file)
          }
        }
      end

      def request_encoding
        content_type = @options.dig(:headers, 'Content-Type')
        content_type&.include?('urlencoded') ? :url_encoded : :json
      end

      def install_logger(builder)
        builder.response :logger, @logger, bodies: false, log_level: :debug do |formatter|
          formatter.filter(/(Authorization: )".*?"/i, '\1"[FILTERED]"')
          formatter.filter(/(Proxy-Authorization: )".*?"/i, '\1"[FILTERED]"')
          formatter.filter(/((?:password|token|api[_-]?key)=)[^&\s"]+/i, '\1[FILTERED]')
        end
      end
    end
  end
end
