require 'logger'
require 'roqua/support/helpers'
require 'roqua/support/log_wrapper'
require 'roqua/support/errors'
require 'roqua/support/stats'

module Roqua
  class << self
    def appname
      @appname
    end

    def appname=(name)
      @appname = name
    end

    def logger
      @logger ||= LogWrapper.new(Logger.new(STDOUT))
    end

    def logger=(logger)
      @logger = LogWrapper.new(logger)
    end

    def stats
      @stats ||= Stats.new
    end

    def stats=(stats)
      @stats = stats
    end
  end
end
