require 'English'
require 'thor'

module Crosstest
  module Core
    class CLI < Thor
      # Common module to load and invoke a CLI-implementation agnostic command.
      module PerformCommand
        attr_reader :action

        # Perform a scenario subcommand.
        #
        # @param task [String] action to take, usually corresponding to the
        #   subcommand name
        # @param command [String] command class to create and invoke]
        # @param args [Array] remainder arguments from processed ARGV
        #   (default: `nil`)
        # @param additional_options [Hash] additional configuration needed to
        #   set up the command class (default: `{}`)
        def perform(task, command, args = nil, additional_options = {})
          require "crosstest/command/#{command}"

          command_options = {
            help: -> { help(task) },
            test_dir: @test_dir,
            shell: shell
          }.merge(additional_options)

          str_const = Thor::Util.camel_case(command)
          klass = ::Crosstest::Command.const_get(str_const)
          klass.new(task, args, options, command_options).call
        end
      end

      include Core::Logging
      include PerformCommand

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
