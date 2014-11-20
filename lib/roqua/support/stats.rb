require 'naught'

module Roqua
  module Support
    class Stats
      NullBackend = Naught.build do |config|
        config.singleton
      end

      attr_reader :backend

      def initialize(backend = NullBackend.instance)
        @backend = backend
      end

      # Report a value to the stats backend
      def submit(key, value)
        backend.submit(prefix(key), value)
      end

      private

      def prefix(key)
        "#{Roqua.appname}.#{key}"
      end
    end
  end
end
