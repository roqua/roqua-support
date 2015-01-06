require 'spec_helper'
require 'rspec-instrumentation-matcher'
require 'active_interaction'
require 'active_support/all'
require 'roqua/core_ext/active_interaction/rails_instrumentation'

class AIRailsInstrumentationTest < ActiveInteraction::Base
  string :foo, default: 'bar'

  def execute
  end
end

describe RoquaRailsActiveInteractionInstrumentation do
  include RSpec::Instrumentation::Matcher
  it 'creates an event' do
    expect { AIRailsInstrumentationTest.run }.to instrument('operation.active_interaction').with(
      class_name: 'ai_rails_instrumentation_test')
  end
end
