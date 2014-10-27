require 'rubygems'
require 'bundler/setup'

require 'combustion'

Combustion.initialize! :action_controller

module ActiveRecord; module VERSION; STRING = '4'; end; end # needed since one test defines ActiveRecord making next line think it's actually loaded.
require 'rspec/rails'
