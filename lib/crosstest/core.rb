require 'crosstest/core/version'
require 'logger'
require 'cause'
require 'thor'
require 'pathname'
require 'crosstest/errors'

module Crosstest
  module Core
    autoload :Configurable, 'crosstest/core/configurable'
    autoload :Util, 'crosstest/core/util'
    autoload :FileSystem, 'crosstest/core/file_system'
    autoload :CLI, 'crosstest/core/cli'
    autoload :Logger, 'crosstest/core/logger'
    autoload :Logging, 'crosstest/core/logging'
    autoload :DefaultLogger, 'crosstest/core/logging'
    autoload :StdoutLogger, 'crosstest/core/logging'
    autoload :LogdevLogger, 'crosstest/core/logging'
    autoload :Color, 'crosstest/core/color'
    autoload :Dash, 'crosstest/core/hashie'
    autoload :Mash, 'crosstest/core/hashie'
  end

  include Crosstest::Core::Logger
  include Crosstest::Core::Logging

  class << self
    # @return [Logger] the common Crosstest logger
    attr_accessor :logger

    # @return [Mutex] a common mutex for global coordination
    attr_accessor :mutex

    def basedir
      @basedir ||= Dir.pwd
    end

    def logger
      @logger ||= Core::StdoutLogger.new($stdout)
    end

    # Determine the default log level from an environment variable, if it is
    # set.
    #
    # @return [Integer,nil] a log level or nil if not set
    # @api private
    def env_log
      level = ENV['CROSSTEST_LOG'] && ENV['CROSSTEST_LOG'].downcase.to_sym
      level = Util.to_logger_level(level) unless level.nil?
      level
    end

    # Default log level verbosity
    DEFAULT_LOG_LEVEL = :info
  end
end
