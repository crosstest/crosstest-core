# -*- encoding: utf-8 -*-
#
# Much of this code has been adapted from Fletcher Nichol (<fnichol@nichol.ca>)
# work on test-kitchen.

module Crosstest
  module Core
    # Stateless utility methods used in different contexts. Essentially a mini
    # PassiveSupport library.
    module Util
      module Hashable
        def to_hash
          instance_variables.each_with_object({}) do |var, hash|
            hash[var.to_s.delete('@')] = instance_variable_get(var)
          end
        end
      end

      # Returns the standard library Logger level constants for a given symbol
      # representation.
      #
      # @param symbol [Symbol] symbol representation of a logger level (:debug,
      #   :info, :warn, :error, :fatal)
      # @return [Integer] Logger::Severity constant value or nil if input is not
      #   valid
      def self.to_logger_level(symbol)
        return nil unless [:debug, :info, :warn, :error, :fatal].include?(symbol)

        ::Logger.const_get(symbol.to_s.upcase)
      end

      # Returns the symbol represenation of a logging levels for a given
      # standard library Logger::Severity constant.
      #
      # @param const [Integer] Logger::Severity constant value for a logging
      #   level (Logger::DEBUG, Logger::INFO, Logger::WARN, Logger::ERROR,
      #   Logger::FATAL)
      # @return [Symbol] symbol representation of the logging level
      def self.from_logger_level(const)
        case const
        when ::Logger::DEBUG then :debug
        when ::Logger::INFO then :info
        when ::Logger::WARN then :warn
        when ::Logger::ERROR then :error
        else :fatal
        end
      end

      # Returns a new Hash with all key values coerced to symbols. All keys
      # within a Hash are coerced by calling #to_sym and hashes within arrays
      # and other hashes are traversed.
      #
      # @param obj [Object] the hash to be processed. While intended for
      #   hashes, this method safely processes arbitrary objects
      # @return [Object] a converted hash with all keys as symbols
      def self.symbolized_hash(obj)
        if obj.is_a?(Hash)
          obj.each_with_object({}) do |(k, v), h|
            h[k.to_sym] = symbolized_hash(v)
          end
        elsif obj.is_a?(Array)
          obj.each_with_object([]) do |e, a|
            a << symbolized_hash(e)
          end
        else
          obj
        end
      end

      # Returns a new Hash with all key values coerced to strings. All keys
      # within a Hash are coerced by calling #to_s and hashes with arrays
      # and other hashes are traversed.
      #
      # @param obj [Object] the hash to be processed. While intended for
      #   hashes, this method safely processes arbitrary objects
      # @return [Object] a converted hash with all keys as strings
      def self.stringified_hash(obj)
        if obj.is_a?(Hash)
          obj.each_with_object({}) do |(k, v), h|
            h[k.to_s] = stringified_hash(v)
          end
        elsif obj.is_a?(Array)
          obj.each_with_object([]) do |e, a|
            a << stringified_hash(e)
          end
        else
          obj
        end
      end

      # Returns a formatted string representing a duration in seconds.
      #
      # @param total [Integer] the total number of seconds
      # @return [String] a formatted string of the form (XmYY.00s)
      def self.duration(total)
        total = 0 if total.nil?
        minutes = (total / 60).to_i
        seconds = (total - (minutes * 60))
        format('(%dm%.2fs)', minutes, seconds)
      end

      module String
        module ClassMethods
          def slugify(*labels)
            labels.map do |label|
              label.downcase.gsub(/[\.\s-]/, '_')
            end.join('-')
          end

          def ansi2html(text)
            HTML.from_ansi(text)
          end

          def escape_html(text)
            HTML.escape_html(text)
          end
          alias_method :h, :escape_html

          def highlight(source, opts = {})
            return nil if source.nil?

            opts[:language] ||= 'ruby'
            opts[:formatter] ||= 'terminal256'
            Highlight.new(opts).highlight(source)
          end
        end

        def self.included(base)
          base.extend(ClassMethods)
        end

        include ClassMethods
      end

      class Highlight
        def initialize(opts)
          @lexer = Rouge::Lexer.find(opts[:language]) || Rouge::Lexer.guess_by_filename(opts[:filename])
          @formatter = opts[:formatter]
        end

        def highlight(source)
          Rouge.highlight(source, @lexer, @formatter)
        end
      end

      class HTML
        ANSICODES = {
          '1' => 'bold',
          '4' => 'underline',
          '30' => 'black',
          '31' => 'red',
          '32' => 'green',
          '33' => 'yellow',
          '34' => 'blue',
          '35' => 'magenta',
          '36' => 'cyan',
          '37' => 'white',
          '40' => 'bg-black',
          '41' => 'bg-red',
          '42' => 'bg-green',
          '43' => 'bg-yellow',
          '44' => 'bg-blue',
          '45' => 'bg-magenta',
          '46' => 'bg-cyan',
          '47' => 'bg-white'
        }

        def self.from_ansi(text)
          ansi = StringScanner.new(text)
          html = StringIO.new
          until ansi.eos?
            if ansi.scan(/\e\[0?m/)
              html.print(%(</span>))
            elsif ansi.scan(/\e\[0?(\d+)m/)
              # use class instead of style?
              style = ANSICODES[ansi[1]] || 'text-reset'
              html.print(%(<span class="#{style}">))
            else
              html.print(ansi.scan(/./m))
            end
          end
          html.string
        end

        # From Rack

        ESCAPE_HTML = {
          '&' => '&amp;',
          '<' => '&lt;',
          '>' => '&gt;',
          "'" => '&#x27;',
          '"' => '&quot;',
          '/' => '&#x2F;'
        }
        ESCAPE_HTML_PATTERN = Regexp.union(*ESCAPE_HTML.keys)

        # Escape ampersands, brackets and quotes to their HTML/XML entities.
        def self.escape_html(string)
          string.to_s.gsub(ESCAPE_HTML_PATTERN) { |c| ESCAPE_HTML[c] }
        end
      end
    end
  end
end
