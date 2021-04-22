# frozen_string_literal: true

module WS
  module HttpClient
    class Logger
      def error(message)
        $stderr.write(message)
      end
    end
  end
end
