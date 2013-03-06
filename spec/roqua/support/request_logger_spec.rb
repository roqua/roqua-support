require 'roqua/support/logging'
require 'roqua/support/request_logger'
require 'active_support/notifications'
require 'active_support/core_ext/string'

describe Roqua::Support::RequestLogger do
  let(:logstream)  { StringIO.new }
  let(:logger)     { Logger.new(logstream) }
  let(:logwrapper) { Roqua::LogWrapper.new(logger) }

  before { Roqua.stub(logger: logwrapper) }

  def log
    logstream.string
  end

  let(:subscriber) { Roqua::Support::RequestLogger.new }

  context 'when processing a request' do
    let(:event) do
      ActiveSupport::Notifications::Event.new('process_action.action_controller',
                                              Time.new(2013, 02, 28, 12, 34, 56),
                                              Time.new(2013, 02, 28, 12, 34, 57), 2,
          status: 200, format: 'application/json', method: 'GET', path: '/home?foo=bar',
          params: {'controller' => 'home', 'action' => 'index', 'foo' => 'bar'},
          db_runtime: 0.02, view_runtime: 0.01
      )
    end

    it "logs the URL" do
      subscriber.process_action(event)
      logstream.string.should include('/home')
    end

    it "does not log the query string" do
      subscriber.process_action(event)
      logstream.string.should_not include('?foo=bar')
    end

    it "logs the HTTP method" do
      subscriber.process_action(event)
      logstream.string.should include('method="GET"')
    end

    it "logs the status code returned" do
      subscriber.process_action(event)
      logstream.string.should include('status=200 ')
    end

    it "logs the controller and action" do
      subscriber.process_action(event)
      logstream.string.should include('controller="home" action="index"')
    end

    it 'logs request parameters' do
      subscriber.process_action(event)
      logstream.string.should include('params={"foo"=>"bar"}')
    end

    it "logs how long the request took" do
      subscriber.process_action(event)
      logstream.string.should =~ /duration=1000.0000 /
    end

    it "logs the view rendering time" do
      subscriber.process_action(event)
      logstream.string.should =~ /view=0.0100 /
    end

    it "logs the database rendering time" do
      subscriber.process_action(event)
      logstream.string.should =~ /db=0.0200/
    end

    it 'logs extra information added in the controller' do
      controller = Class.new do
        include Roqua::Support::RequestLogging

        def index
          add_log_information 'current_user', 'johndoe'
        end
      end
      controller.new.index
      subscriber.process_action(event)
      logstream.string.should include('current_user="johndoe"')

      # next request should not still maintain this data
      logstream.truncate 0
      subscriber.process_action(event)
      logstream.string.should_not include('current_user')
    end
  end

  context 'when an exception occured processing the request' do
    let(:event) do
      ActiveSupport::Notifications::Event.new('process_action.action_controller',
                                              Time.now, Time.now, 2,
          status: nil, format: 'application/json', method: 'GET', path: '/home?foo=bar',
          exception: ['AbstractController::ActionNotFound', 'Route not found'],
          params: {'controller' => 'home', 'action' => 'index', 'foo' => 'bar'},
          db_runtime: 0.02, view_runtime: 0.01
      )
    end

    it "logs the 500 status when an exception occurred" do
      subscriber.process_action(event)
      logstream.string.should =~ /status=500 /
      logstream.string.should =~ /error="AbstractController::ActionNotFound:Route not found" /
    end

    it "should return an unknown status when no status or exception is found" do
      event.payload[:status] = nil
      event.payload[:exception] = nil
      subscriber.process_action(event)
      logstream.string.should =~ /status=0 /
    end
  end

  context 'when the request redirected' do
    let(:event) do
      ActiveSupport::Notifications::Event.new('process_action.action_controller',
                                              Time.new(2013, 02, 28, 12, 34, 56),
                                              Time.new(2013, 02, 28, 12, 34, 57), 2,
          status: 200, format: 'application/json', method: 'GET', path: '/home?foo=bar',
          params: {'controller' => 'home', 'action' => 'index', 'foo' => 'bar'},
          db_runtime: 0.02, view_runtime: 0.01
      )
    end

    let(:redirect) {
      ActiveSupport::Notifications::Event.new(
        'redirect_to.action_controller', Time.now, Time.now, 1, location: 'http://example.com', status: 302
      )
    }

    it 'logs the redirect' do
      subscriber.redirect_to(redirect)
      subscriber.process_action(event)
      log.should include('location="http://example.com"')

      # next request should no longer get location
      logstream.truncate 0
      subscriber.process_action(event)
      log.should_not include('location=')
    end
  end
end
