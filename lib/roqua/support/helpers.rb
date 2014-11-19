require 'active_support/core_ext/module/aliasing'
require 'roqua/support/log_wrapper'

module Roqua
  module Support
    module Helpers
      def with_instrumentation(message, options = {})
        started_at = Time.now.to_f
        Roqua.logger.info("#{message}:started", options)
        value = yield
        finished_at = Time.now.to_f
        duration = finished_at - started_at
        Roqua.logger.info("#{message}:finished", {duration: duration}.merge(options))
        Roqua.stats.increment("#{message}.finished")
        Roqua.stats.measure("#{message}.duration", duration)
        value
      rescue => e
        Roqua.logger.error("#{message}:failed", {exception: e.class.name, message: e.message}.merge(options))
        Roqua.stats.increment("#{message}.failed")
        raise
      end
    end
  end
end
