require "spec_helper"

require 'roqua/responders/active_interaction_aware_responder'
class AIAResponder < ActionController::Responder
  include Roqua::Responders::ActiveInteractionAwareResponder
end

require 'active_interaction'
class TestInteraction < ActiveInteraction::Base
  string :some_string
  def execute
    {foo: some_string}
  end
end

class ApplicationController < ActionController::Base
  respond_to :json
end

describe Roqua::Responders::ActiveInteractionAwareResponder, type: :controller do
  context 'with a valid interaction' do
    controller do
      self.responder  = AIAResponder
      def index
        use_case = TestInteraction.run some_string: 'bla'
        respond_with use_case
      end
    end

    subject { get :index, format: :json }

    it 'returns the result if valid' do
      subject
      expect(response.body).to eq '{"foo":"bla"}'
    end

  end

  context 'with an invalid interaction' do
    controller do
      self.responder  = AIAResponder
      def index
        use_case = TestInteraction.run
        respond_with use_case
      end
    end
    subject { post :index, format: :json }

    it 'returns the interaction' do
      subject
      expect(response.body).to eq '{"errors":{"some_string":["is required"]}}'
    end
  end
end
