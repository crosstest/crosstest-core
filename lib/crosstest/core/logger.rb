require 'logger'

module Crosstest
  module Core
    module Logger
      def logger
        @logger ||= new_logger
      end

      def new_logger(io = $stdout, level = :debug)
        stdout_logger(io).tap do | logger |
          logger.level = Util.to_logger_level(level)
        end
      end

      # Construct a new standard out logger.
      #
      # @param stdout [IO] the IO object that represents stdout (or similar)
      # @param color [Symbol] color to use when outputing messages
      # @return [StdoutLogger] a new logger
      # @api private
      def stdout_logger(stdout, color = nil)
        logger = Crosstest::Core::StdoutLogger.new(stdout)
        # if Crosstest.tty?
        if stdout.tty? && color
          logger.formatter = proc do |_severity, _datetime, _progname, msg|
            Core::Color.colorize("#{msg}", color).concat("\n")
          end
        else
          logger.formatter = proc do |_severity, _datetime, _progname, msg|
            msg.concat("\n")
          end
        end
        logger
      end

      def log_level=(level)
        logger.level = level
      end
    end
  end
end
