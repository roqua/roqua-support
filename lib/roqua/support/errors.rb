module Roqua
  module Support
    module Errors
      class Wrap < StandardError
        def initialize(parameters = {})
          @parameters = parameters
        end

        def parameters
          return {} unless @parameters.is_a? Hash
          @parameters
        end
      end

      def self.extra_parameters
        @extra_parameters || {}
      end

      def self.extra_parameters=(hash)
        fail 'not a hash' unless hash.is_a? Hash
        @extra_parameters = hash
      end

      def self.report(exception, context = {})
        return if const_defined?(:Rails) and Rails.env.test?
        context = {} unless context.is_a? Hash

        parameters, controller, skip_backtrace = merge_parameters(exception, context)
        exception = exception.cause if exception.is_a? Roqua::Support::Errors::Wrap

        notification_urls = [notify_airbrake(exception, controller, parameters),
                             notify_appsignal(exception, parameters)]
        # Notify Roqua logging
        log_exception(exception, parameters, notification_urls.compact, skip_backtrace)
      end

      private

      def self.merge_parameters(exception, context = {})
        parameters = extra_parameters.dup
        controller = context.delete :controller
        skip_backtrace = context.delete :skip_backtrace
        parameters.merge! context
        parameters.merge! exception.parameters if exception.is_a? Roqua::Support::Errors::Wrap
        [parameters, controller, skip_backtrace]
      rescue Exception
      end

      def self.log_exception(exception, parameters = {}, notification_urls = [], skip_backtrace = false)
        if Roqua.respond_to?(:logger)
          exception_info = {class_name: exception.class.to_s,
                            message: exception.message,
                            parameters: parameters}
          exception_info[:notification_urls] = notification_urls if notification_urls.present?
          exception_info[:backtrace] = exception.backtrace unless skip_backtrace
          puts exception_info.inspect
          Roqua.logger.error('roqua.exception', exception_info)
        end
      rescue Exception
      end

      def self.notify_airbrake(exception, controller, parameters = {})
        if const_defined?(:Airbrake)
          if controller && controller.respond_to?(:airbrake_request_data)
            request_data = controller.airbrake_request_data
            if request_data.is_a?(Hash)
              request_data[:parameters] ||= {}
              if request_data[:parameters].is_a?(Hash)
                request_data[:parameters] = parameters.merge request_data[:parameters]
              end
            else
              request_data = nil
            end
          end
          request_data ||= {parameters: parameters}
          uuid = Airbrake.notify_or_ignore(exception, request_data)
          "https://airbrake.io/locate/#{uuid}" if uuid
        end
      rescue Exception
      end

      def self.notify_appsignal(exception, parameters = {})
        if const_defined?(:Appsignal) and
           not Appsignal.is_ignored_exception?(exception)
          # TODO: If and when https://github.com/appsignal/appsignal/pull/9 is merged,
          # this functionality should be supported directly by Appsignal.send_exception.
          # Appsignal.send_exception(exception, parameters: parameters)

          if Appsignal.active?
            # Hackety hack around stateful mess of Appsignal gem
            if Appsignal::Transaction.current
              Appsignal::Transaction.current.set_tags(parameters)
              Appsignal::Transaction.current.add_exception(exception)
            else
              transaction = Appsignal::Transaction.create(SecureRandom.uuid, ENV.to_hash)
              transaction.set_tags(parameters)
              transaction.add_exception(exception)
              transaction.complete!
              Appsignal.agent.send_queue
            end
          end
        end
      rescue Exception
      end
    end
  end
end
