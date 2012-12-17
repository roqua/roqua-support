require 'active_support/core_ext/module/aliasing'
require 'roqua/support/log_wrapper'

module Roqua
  module Logging
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def log(method_name, message, options = {})
        define_method(:"#{method_name}_with_log") do |*args, &block|
          logger.lifecycle(message, options) do
            send(:"#{method_name}_without_log", *args, &block)
          end
        end

        alias_method_chain method_name, 'log'
      end
    end

    def logger
      Roqua.logger
    end
  end
end