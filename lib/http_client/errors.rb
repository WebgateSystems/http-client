# frozen_string_literal: true

module WS
  module HttpClient
    class Error < StandardError; end

    class RequestError < Error; end
    class TimeoutError < RequestError; end
    class ConnectionError < RequestError; end

    # Raised when the response status is outside expected_statuses.
    # A 4xx or 5xx status is not a transport failure: the server did answer.
    class UnexpectedStatusError < Error
      attr_reader :status, :response

      def initialize(response)
        @response = response
        @status = response.status
        super("Unexpected HTTP status: #{status}")
      end
    end
  end
end
