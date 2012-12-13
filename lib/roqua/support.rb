require 'logger'
require 'roqua/support/logging'

module Roqua
  class << self
    def logger
      @logger ||= LogWrapper.new(Logger.new(STDOUT))
    end

    def logger=(logger)
      @logger = LogWrapper.new(logger)
    end
  end
end