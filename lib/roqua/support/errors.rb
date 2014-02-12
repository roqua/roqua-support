module Roqua
  module Support
    module Errors
      def self.extra_parameters
        @extra_parameters || {}
      end

      def self.extra_parameters=(hash)
        @extra_parameters = hash
      end

      def self.report(exception, extra_params = {})
        return if const_defined?(:Rails) and Rails.env.test?
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
        if const_defined?(:Appsignal) and
           not Appsignal.is_ignored_exception?(exception)
          # TODO: If and when https://github.com/appsignal/appsignal/pull/9 is merged,
          # this functionality should be supported directly by Appsignal.send_exception.
          # Appsignal.send_exception(exception, parameters: parameters)

          if Appsignal.active?
            transaction = Appsignal::Transaction.create(SecureRandom.uuid, ENV.to_hash)
            transaction.set_tags(parameters)
            transaction.add_exception(exception)
            transaction.complete!
            Appsignal.agent.send_queue
          end
        end
      end
    end
  end
end