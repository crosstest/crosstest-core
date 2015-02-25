module Omnitest
  module Core
    module DefaultLogger
      module ClassMethods
        def logger
          @logger ||= default_logger
        end

        def default_logger
          if Omnitest.respond_to? :configuration
            Omnitest.configuration.default_logger
          else
            ::Logger.new(STDOUT)
          end
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      include ClassMethods
    end

    module Logging
      class << self
        private

        def logger_method(meth)
          define_method(meth) do |*args|
            logger.public_send(meth, *args)
          end
        end
      end

      logger_method :banner
      logger_method :debug
      logger_method :info
      logger_method :warn
      logger_method :error
      logger_method :fatal
    end

    # Internal class which adds a #banner method call that displays the
    # message with a callout arrow.
    class LogdevLogger < ::Logger
      alias_method :super_info, :info

      # Dump one or more messages to info.
      #
      # @param msg [String] a message
      def <<(msg)
        @buffer ||= ''
        lines, _, remainder = msg.rpartition("\n")
        if lines.empty?
          @buffer << remainder
        else
          lines.insert(0, @buffer)
          lines.split("\n").each { |l| format_line(l.chomp) }
          @buffer = ''
        end
      end

      # Log a banner message.
      #
      # @param msg [String] a message
      def banner(msg = nil, &block)
        super_info("-----> #{msg}", &block)
      end

      private

      # Reformat a line if it already contains log formatting.
      #
      # @param line [String] a message line
      # @api private
      def format_line(line)
        case line
        when /^-----> / then banner(line.gsub(/^[ >-]{6} /, ''))
        when /^>>>>>> / then error(line.gsub(/^[ >-]{6} /, ''))
        when /^       / then info(line.gsub(/^[ >-]{6} /, ''))
        else info(line)
        end
      end
    end

    # Internal class which reformats logging methods for display as console
    # output.
    class StdoutLogger < LogdevLogger
      # Log a debug message
      #
      # @param msg [String] a message
      def debug(msg = nil, &block)
        super("D      #{msg}", &block)
      end

      # Log an info message
      #
      # @param msg [String] a message
      def info(msg = nil, &block)
        super("       #{msg}", &block)
      end

      # Log a warn message
      #
      # @param msg [String] a message
      def warn(msg = nil, &block)
        super("$$$$$$ #{msg}", &block)
      end

      # Log an error message
      #
      # @param msg [String] a message
      def error(msg = nil, &block)
        super(">>>>>> #{msg}", &block)
      end

      # Log a fatal message
      #
      # @param msg [String] a message
      def fatal(msg = nil, &block)
        super("!!!!!! #{msg}", &block)
      end

      # Log an unknown message
      #
      # @param msg [String] a message
      def unknown(msg = nil, &block)
        super("?????? #{msg}", &block)
      end
    end
  end
end
