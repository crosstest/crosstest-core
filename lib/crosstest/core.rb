require 'crosstest/core/version'
require 'logger'
require 'cause'
require 'thor'
require 'pathname'

module Crosstest
  module Core
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
end
