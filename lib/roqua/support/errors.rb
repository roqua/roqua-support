module Roqua
  module Support
    module Errors
      # global extra parameters to be added to all reports.
      def self.extra_parameters
        @extra_parameters || {}
      end

      def self.extra_parameters=(hash)
        fail 'not a hash' unless hash.is_a? Hash
        @extra_parameters = hash
      end

      # adds instance variable roqua_extra_parameters to current exception.
      def self.add_parameters(params)
        return unless params.is_a?(Hash) && $!
        $!.instance_eval do
          (@roqua_extra_parameters ||= {}).merge! params
        end
      end

      def self.report(exception, context = {})
        return if const_defined?(:Rails) and Rails.env.test?
        context = {} unless context.is_a? Hash

        parameters, controller, skip_backtrace = merge_parameters(exception, context)

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
        parameters.merge! extra_parameters_from_exception(exception)
        [parameters, controller, skip_backtrace]
      rescue Exception
      end

      def self.extra_parameters_from_exception(exception)
        exception.instance_variable_get(:@roqua_extra_parameters) || {}
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
          #
          transaction_type = transaction_type_for_category parameters.delete(:category)

          if Appsignal.active?
            # Hackety hack around stateful mess of Appsignal gem
            if Appsignal::Transaction.current
              Appsignal::Transaction.current.set_tags(parameters)
              Appsignal::Transaction.current.add_exception(exception)
            else
              transaction = Appsignal::Transaction.create(SecureRandom.uuid, transaction_type, Appsignal::Transaction::GenericRequest.new({}))
              transaction.set_tags(parameters)
              transaction.add_exception(exception)
              transaction.complete_current!
              Appsignal.agent.send_queue
            end
          end
        end
      end

      def self.transaction_type_for_category(category = nil)
        case category
        when :background then Appsignal::Transaction::BACKGROUND_JOB
        when :web then        Appsignal::Transaction::HTTP_REQUEST
        else                  Appsignal::Transaction::BLANK
        end
      end
    end
  end
end
