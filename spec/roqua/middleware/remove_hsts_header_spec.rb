require 'spec_helper'

# Fake rack application
class MockRackApp
  attr_reader :request_body

  def initialize
    @request_headers = {}
  end

  def call(env)
    @env = env
    @request_body = env['rack.input'].read
    [200, { 'Content-Type' => 'text/plain',
            'Strict-Transport-Security' => 'foo' }, ['OK']]
  end

  def [](key)
    @env[key]
  end
end

describe Roqua::Middleware::RemoveHstsHeader do
  let(:app) { MockRackApp.new }
  subject { Roqua::Middleware::RemoveHstsHeader.new(app) }

  let(:request) { Rack::MockRequest.new(subject) }

  it 'removes the hsts header' do
    response = request.get('/some/path', 'CONTENT_TYPE' => 'text/plain')

    expect(response.headers.keys).to_not include('Strict-Transport-Security')
  end
end
