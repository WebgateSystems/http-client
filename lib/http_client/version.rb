# frozen_string_literal: true
module WS
  module HttpClient
    module VERSION

      MAJOR = 1
      MINOR = 0
      PATCH = 0
      BUILD = 'edge'

      STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join('.')

      def self.version
        STRING
      end

    end
  end
end
