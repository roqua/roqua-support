require 'logger'
require 'roqua/support/logging'
require 'roqua/support/errors'

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
  end
end