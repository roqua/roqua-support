require 'rubygems'
require 'bundler/setup'

require 'combustion'

Combustion.schema_format = :sql
Combustion.initialize! :action_controller

module ActiveRecord
  module VERSION
    STRING = '4'
  end
end
require 'rspec/rails'
