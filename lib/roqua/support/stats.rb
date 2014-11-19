require 'naught'

module Roqua
  class Stats
    NullBackend = Naught.build do |config|
      config.singleton
    end

    attr_reader :backend

    def initialize(backend = NullBackend.instance)
      @backend = backend
    end

    # Lets you benchmark how long the execution of a specific method takes.
    def measure(key, duration)
      backend.measure(prefix(key), duration)
    end

    # Lets you increment a key in statsd to keep a count of something.
    def increment(key, amount = 1)
      backend.increment(prefix(key), amount)
    end

    # A gauge is a single numerical value value that tells you the state of the system
    # at a point in time. A good example would be the number of messages in a queue.
    def gauge(key, value)
      backend.gauge(prefix(key), value)
    end

    # A set keeps track of the number of unique values that have been seen. This
    # is a good fit for keeping track of the number of unique visitors. The identifier
    # can be a string.
    def set(key, identifier)
      backend.set(prefix(key), identifier)
    end

    private

    def prefix(key)
      "#{Roqua.appname}.#{key}"
    end
  end
end
