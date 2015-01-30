require 'logger'

module Crosstest
  module Core
    module Logger
      def logger
        @logger ||= new_logger
      end

      def new_logger(io = $stdout, level = :debug)
        StdoutLogger.new(io).tap do | logger |
          logger.level = Util.to_logger_level(level)
        end
      end

      def log_level=(level)
        logger.level = level
      end
    end
  end
end
