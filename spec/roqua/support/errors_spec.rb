require 'spec_helper'
require 'roqua/support/errors'

describe 'Error reporting' do
  let(:exception) do
    Exception.new('exception_message').tap do |exception|
      exception.set_backtrace ['back', 'trace', 'lines']
    end
  end

  let(:logstream)  { StringIO.new }
  let(:logger)     { Logger.new(logstream) }
  let(:logwrapper) { Roqua::LogWrapper.new(logger) }

  before do
    Rails.env = 'foo' # in test we don't log
    Roqua.logger = logwrapper
  end

  it 'sends notifications to the eventlog' do
    Roqua.logger.should_receive(:error).with('roqua.exception',
                                             class_name: 'Exception',
                                             message: 'exception_message',
                                             backtrace: ['back', 'trace', 'lines'],
                                             parameters: {})
    Roqua::Support::Errors.report exception
  end

  it 'sends the airbrake notification id to the eventlog when present' do
    stub_const('Airbrake', double('Airbrake', notify_or_ignore: 'airbrake_notification_uuid'))
    Roqua.logger.should_receive(:error)
                .with('roqua.exception',
                      class_name: 'Exception',
                      message: 'exception_message',
                      airbrake_notification: 'https://airbrake.io/locate/airbrake_notification_uuid',
                      parameters: {})
    Roqua::Support::Errors.report exception
  end

  context 'when Airbrake is defined' do
    before do
      stub_const('Airbrake', double('Airbrake', is_ignored_exception?: false))
    end

    it 'sends notifications to airbrake' do
      Airbrake.should_receive(:notify_or_ignore).with(exception, parameters: {})
      Roqua::Support::Errors.report exception
    end

    it 'adds request data when a controller is passed in' do
      controller = double(airbrake_request_data: {request: 'data', parameters: {request: 'param'}})
      expect(Airbrake).to receive(:notify_or_ignore)
                      .with(exception, request: 'data', parameters: {request: 'param', some: 'context'})
      Roqua::Support::Errors.report exception, controller: controller, some: 'context'
    end

    it 'does not fail with extra parameters of incompatible type' do
      Roqua::Support::Errors.extra_parameters = ['extra', 'param']
      expect(Airbrake).to receive(:notify_or_ignore).with(exception, parameters: {})
      Roqua::Support::Errors.report exception
      Roqua::Support::Errors.extra_parameters = {}
    end

    it 'does not fail with context of incompatible type' do
      expect(Airbrake).to receive(:notify_or_ignore).with(exception, parameters: {})
      Roqua::Support::Errors.report exception, ['controller', 'extra_param']
    end

    it 'does not fail with request data of incompatible type' do
      controller = double(airbrake_request_data: ['request', 'data'])
      expect(Airbrake).to receive(:notify_or_ignore).with(exception, parameters: {})
      Roqua::Support::Errors.report exception, controller: controller
    end
  end

  context 'when Appsignal is loaded' do
    let(:agent)       { double("agent") }
    let(:transaction) { double("transaction") }

    it 'sends notifications to appsignal when there is no current exception' do
      stub_const("Appsignal", Module.new)
      Appsignal.stub(active?: true)
      Appsignal.stub(is_ignored_exception?: false, agent: agent)
      stub_const("Appsignal::Transaction", double("Transaction", create: transaction, current: nil))

      transaction.should_receive(:set_tags).with({})
      transaction.should_receive(:add_exception).with(exception)
      transaction.should_receive(:complete!)
      agent.should_receive(:send_queue)
      Roqua::Support::Errors.report exception
    end

    it 'sends notifications to appsignal when there already is a current exception' do
      stub_const("Appsignal", Module.new)
      Appsignal.stub(active?: true)
      Appsignal.stub(is_ignored_exception?: false, agent: agent)
      stub_const("Appsignal::Transaction", double("Transaction", current: transaction))

      transaction.should_receive(:set_tags).with({})
      transaction.should_receive(:add_exception).with(exception)
      Roqua::Support::Errors.report exception
    end
  end

  it 'supports default extra params' do
    Roqua::Support::Errors.stub(extra_parameters: {organization: 'some_org'})
    Roqua.logger.should_receive(:error).with('roqua.exception',
                                             class_name: 'Exception',
                                             message: 'exception_message',
                                             backtrace: ['back', 'trace', 'lines'],
                                             parameters: {organization: 'some_org'})
    Roqua::Support::Errors.report exception
  end
end
