# frozen_string_literal: true

module Roqua
  module Middleware
    # Remove HSTS header because our loadbalancer will already add it instead.
    # Add the following line to config/application.rb in the Rails app:
    #   config.middleware.use Roqua::RemoveHstsHeader
    class RemoveHstsHeader
      def initialize(app, _redirect: {}, _hsts: {}, _secure_cookies: true)
        @app = app
      end

      def call(env)
        @app.call(env).tap do |_status, headers, _body|
          headers.delete('Strict-Transport-Security')
        end
      end
    end
  end
end
