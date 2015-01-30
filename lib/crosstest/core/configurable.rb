module Crosstest
  module Core
    module Configurable
      # @see Crosstest::Configuration
      def configuration
        fail "configuration doesn't take a block, use configure" if block_given?
        @configuration ||= const_get('Configuration').new
      end

      # @see Crosstest::Configuration
      def configure
        yield(configuration)
      end

      def reset
        configuration.clear
        @configuration = nil
      end
    end
  end
end
