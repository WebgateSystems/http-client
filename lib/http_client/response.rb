# frozen_string_literal: true

module WS
  module HttpClient
    class Response
      attr_reader :body, :headers, :status

      def initialize(body:, status:, headers:)
        @body = body
        @headers = headers
        @status = status
      end
    end
  end
end
