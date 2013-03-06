module Roqua
  class LogWrapper
    attr_reader :logger

    def initialize(logger)
      @logger = logger
    end

    def add(level, message, options = {})
      parameters = options.map do |key, value|
        case value
        when Float
          "#{key}=%.4f" % value
        when String
          "#{key}=#{value.inspect}"
        else
          "#{key}=#{value}"
        end
      end.join(" ").gsub("\n", " ")
      logger.send(level, "#{message} #{parameters}".strip)
    end

    [:fatal, :error, :warn, :info, :debug].each do |level|
      define_method(level) do |*args|
        add(level, *args)
      end
    end

    def lifecycle(message, options = {})
      started_at = Time.now.to_f
      info("#{message}:started", options)
      value = yield
      finished_at = Time.now.to_f
      duration = finished_at - started_at
      info("#{message}:finished", {duration: duration}.merge(options))
      value
    rescue => e
      error("#{message}:failed", {exception: e.class, message: e.message}.merge(options))
      raise
    end
  end
end
