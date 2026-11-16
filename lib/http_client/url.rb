# frozen_string_literal: true

require 'uri'

module WS
  module HttpClient
    # Joins a base URL with a path. An absolute endpoint is rejected so it
    # cannot replace the configured host. Query strings on the base URL stay
    # put; request parameters are passed to Faraday separately.
    class Url
      def self.join(base_url, endpoint)
        new(base_url, endpoint).to_s
      end

      def initialize(base_url, endpoint)
        @base_url = base_url.to_s
        @endpoint = endpoint.to_s
      end

      def to_s
        raise ArgumentError, 'Absolute URL not allowed' if absolute?

        base = URI.parse(@base_url)
        base.path = joined_path(base.path)
        base.to_s
      end

      private

      def absolute?
        @endpoint.match?(/\A[a-z][a-z0-9+.-]*:/i) || @endpoint.start_with?('//')
      end

      def joined_path(base_path)
        trimmed_base = base_path.to_s.sub(%r{/+\z}, '')
        trimmed_endpoint = @endpoint.sub(%r{\A/+}, '')
        joined = [trimmed_base, trimmed_endpoint].reject(&:empty?).join('/')
        joined.start_with?('/') ? joined : "/#{joined}"
      end
    end
  end
end
