module Omnitest
  module Core
    module Configurable
      # @see Omnitest::Configuration
      def configuration
        fail "configuration doesn't take a block, use configure" if block_given?
        @configuration ||= const_get('Configuration').new
      end

      # @see Omnitest::Configuration
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
