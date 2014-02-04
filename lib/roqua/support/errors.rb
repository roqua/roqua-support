module Roqua
  module Support
    module Errors
      if const_defined?(:Appsignal)
        module Appsignal
          # TODO: If and when https://github.com/appsignal/appsignal/pull/9 is merged,
          # this functionality should be supported directly by Appsignal.send_exception.
          def send_exception_with_tags(exception, tags = {})
            return if is_ignored_exception?(exception)
            transaction = Appsignal::Transaction.create(SecureRandom.uuid, ENV.to_hash)
            transaction.set_tags(tags)
            transaction.add_exception(exception)
            transaction.complete!
            Appsignal.agent.send_queue
          end
        end
      end

      def self.extra_parameters
        @extra_parameters || {}
      end

      def self.extra_parameters=(hash)
        @extra_parameters = hash
      end

      def self.report(exception, extra_params = {})
        parameters = extra_parameters.merge(extra_params)

        # Notify Roqua logging
        if Roqua.respond_to?(:logger)
          Roqua.logger.error('roqua.exception',
                             class_name: exception.class.to_s,
                             message: exception.message,
                             backtrace: exception.backtrace,
                             parameters: parameters)
        end

        # Notify Airbrake
        if const_defined?(:Airbrake)
          Airbrake.notify_or_ignore(exception, parameters: parameters)
        end

        # Notify AppSignal
        if const_defined?(:Appsignal)
          Appsignal.send_exception_with_tags(exception, parameters: parameters)
        end
      end
    end
  end
end