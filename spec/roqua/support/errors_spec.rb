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

  context 'when the Roqua logger is defined' do
    it 'supports default extra params' do
      Roqua::Support::Errors.stub(extra_parameters: {organization: 'some_org'})
      Roqua.logger.should_receive(:error).with('roqua.exception',
                                               class_name: 'Exception',
                                               message: 'exception_message',
                                               backtrace: ['back', 'trace', 'lines'],
                                               parameters: {organization: 'some_org'})
      Roqua::Support::Errors.report exception
    end

    it 'sends notifications to the eventlog' do
      Roqua.logger.should_receive(:error).with('roqua.exception',
                                               class_name: 'Exception',
                                               message: 'exception_message',
                                               backtrace: ['back', 'trace', 'lines'],
                                               parameters: {})
      Roqua::Support::Errors.report exception
    end

    it 'skips the backtrace when the skip_backtrace flag is set' do
      Roqua.logger.should_receive(:error).with('roqua.exception',
                                               class_name: 'Exception',
                                               message: 'exception_message',
                                               parameters: {})
      Roqua::Support::Errors.report exception, skip_backtrace: true
    end

    it 'can add extra parameters by calling add_parameters' do
      Roqua.logger.should_receive(:error).with \
        'roqua.exception', class_name: 'RuntimeError',
                           message: 'exception_message',
                           parameters: {more: 'params',
                                        even_more: 'params'}
      begin
        begin
          begin
            fail 'exception_message'
          rescue
            Roqua::Support::Errors.add_parameters(more: 'params')
            raise
          end
        rescue
          Roqua::Support::Errors.add_parameters(even_more: 'params')
          raise
        end
      rescue => e
        Roqua::Support::Errors.report e, skip_backtrace: true
      end
    end

    it 'will not fail when called outside of rescue or when passed the wrong format to add_parameters' do
      Roqua.logger.should_receive(:error).with \
        'roqua.exception', class_name: 'RuntimeError',
                           message: 'exception_message',
                           parameters: {}

      begin
        Roqua::Support::Errors.add_parameters('just a string')
        begin
          fail 'exception_message'
        rescue
          Roqua::Support::Errors.add_parameters('just a string')
          raise
        end
      rescue => e
        Roqua::Support::Errors.report e, skip_backtrace: true
      end
    end

    it 'logs notification_urls when present' do
      stub_const('Airbrake', double('Airbrake', notify_or_ignore: 'uuid'))
      Roqua.logger.should_receive(:error)
                  .with('roqua.exception',
                        class_name: 'Exception',
                        message: 'exception_message',
                        backtrace: ['back', 'trace', 'lines'],
                        notification_urls: ['https://airbrake.io/locate/uuid'],
                        parameters: {})
      Roqua::Support::Errors.report exception
    end
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
end
