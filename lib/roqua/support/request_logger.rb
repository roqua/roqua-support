require 'roqua/support'

module Roqua
  module Support
    module RequestLogging
      def add_log_information(key, value)
        Thread.current[:roqua_request_log] ||= {}
        Thread.current[:roqua_request_log][key] = value
      end
    end

    class RequestLogger < ActiveSupport::LogSubscriber
      include Roqua::Logging

      def process_action(event)
        payload = event.payload
        extra_logged_information = Thread.current[:roqua_request_log]
        Thread.current[:roqua_request_log] = {}

        data      = extract_request(payload)
        data.merge! extract_status(payload)
        data.merge! session: session_data(payload)
        data.merge! runtimes(event)
        data.merge!

        eventlog.info 'roqua.web', data
      rescue Exception => e
        eventlog.info 'roqua.web:logerror', {class: e.class, message: e.message}
      end

      private

      def extract_request(payload)
        {
          :method     => payload[:method],
          :path       => extract_path(payload),
          :format     => extract_format(payload),
          :controller => payload[:params]['controller'],
          :action     => payload[:params]['action']
        }
      end

      def extract_path(payload)
        payload[:path].split("?").first
      end

      def extract_format(payload)
        if ::ActionPack::VERSION::MAJOR == 3 && ::ActionPack::VERSION::MINOR == 0
          payload[:formats].first
        else
          payload[:format]
        end
      end

      def extract_status(payload)
        if payload[:status]
          { :status => payload[:status].to_i }
        elsif payload[:exception]
          exception, message = payload[:exception]
          { :status => 500, :error => "#{exception}:#{message}" }
        else
          { :status => 0 }
        end
      end

      def runtimes(event)
        {
          :duration => event.duration,
          :view => event.payload[:view_runtime],
          :db => event.payload[:db_runtime]
        }.inject({}) do |runtimes, (name, runtime)|
          runtimes[name] = runtime.to_f.round(2) if runtime
          runtimes
        end
      end

      def session_data(payload)
        {}
      end
    end
  end
end