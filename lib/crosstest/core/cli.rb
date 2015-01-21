require 'English'
require 'thor'

module Crosstest
  module Core
    class CLI < Thor
      class << self
        # Override Thor's start to strip extra_args from ARGV before it's processed
        attr_accessor :extra_args

        def start(given_args = ARGV, config = {})
          if given_args && (split_pos = given_args.index('--'))
            @extra_args = given_args.slice(split_pos + 1, given_args.length).map do | arg |
              # Restore quotes
              arg.match(/\=/) ? restore_quotes(arg) : arg
            end
            given_args = given_args.slice(0, split_pos)
          end
          super given_args, config
        end

        private

        def restore_quotes(arg)
          lhs, rhs = arg.split('=')
          lhs = "\"#{lhs}\"" if lhs.match(/\s/)
          rhs = "\"#{rhs}\"" if rhs.match(/\s/)
          [lhs, rhs].join('=')
        end
      end

      no_commands do
        def extra_args
          self.class.extra_args
        end
      end
    end
  end
end
