require 'spec_helper'
require 'roqua/responders/api_errors_responder'
class AEResponder < ActionController::Responder
  include Roqua::Responders::ApiErrorsResponder
end

class ApplicationController < ActionController::Base
  respond_to :json
end

class SomeModel
  include ActiveModel::Model

  attr_accessor :name
end

describe Roqua::Responders::ApiErrorsResponder, type: :controller do
  context 'with an invalid model' do
    controller(ApplicationController) do
      self.responder  = AEResponder
      def index
        sm = SomeModel.new name: 'foo'
        sm.errors.add :name, "That is not a real name"
        respond_with sm
      end
    end
    subject { post :index, format: :json }

    it 'returns the errors scoped on the object name' do
      subject
      expect(response.body).to eq '{"errors":{"some_model":{"name":["That is not a real name"]}}}'
    end
  end
end
