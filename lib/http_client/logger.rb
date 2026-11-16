# frozen_string_literal: true

require 'logger'

module WS
  module HttpClient
    # Stdlib logger with a level and a trailing newline.
    # Request traces are debug. Set VERBOSE=1 to print them.
    class Logger < ::Logger
      def initialize(io = $stderr)
        super
        self.level = self.class.verbose? ? ::Logger::DEBUG : ::Logger::INFO
        self.formatter = proc { |severity, _time, _progname, message|
          "#{severity}: #{message}\n"
        }
      end

      def self.verbose?
        value = ENV.fetch('VERBOSE') { '' }
        !value.empty? && !%w[0 false no].include?(value.downcase)
      end
    end
  end
end
