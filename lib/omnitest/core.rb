require 'omnitest/core/version'
require 'forwardable'
require 'logger'
require 'cause'
require 'thor'
require 'pathname'
require 'omnitest/errors'

module Omnitest
  module Core
    autoload :Configurable, 'omnitest/core/configurable'
    autoload :Util, 'omnitest/core/util'
    autoload :FileSystem, 'omnitest/core/file_system'
    autoload :CLI, 'omnitest/core/cli'
    autoload :Logger, 'omnitest/core/logger'
    autoload :Logging, 'omnitest/core/logging'
    autoload :DefaultLogger, 'omnitest/core/logging'
    autoload :StdoutLogger, 'omnitest/core/logging'
    autoload :LogdevLogger, 'omnitest/core/logging'
    autoload :Color, 'omnitest/core/color'
    autoload :Dash, 'omnitest/core/hashie'
    autoload :Mash, 'omnitest/core/hashie'
  end

  include Omnitest::Core::Logger
  include Omnitest::Core::Logging

  class << self
    # @return [Logger] the common Omnitest logger
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
