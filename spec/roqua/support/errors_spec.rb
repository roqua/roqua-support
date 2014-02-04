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

  it 'sends notifications to airbrake' do
    stub_const("Airbrake", double("Airbrake"))
    Airbrake.should_receive(:notify_or_ignore).with(exception, parameters: {})
    Roqua::Support::Errors.report exception
  end

  it 'sends notifications to appsignal' do
    stub_const("Appsignal", double("Appsignal"))
    Appsignal.should_receive(:send_exception_with_tags).with(exception, parameters: {})
    Roqua::Support::Errors.report exception
  end

  it 'supports default extra params' do
    Roqua::Support::Errors.extra_parameters = {organization: 'some_org'}
    Roqua.logger.should_receive(:error).with('roqua.exception',
                                             class_name: 'Exception',
                                             message: 'exception_message',
                                             backtrace: ['back', 'trace', 'lines'],
                                             parameters: {organization: 'some_org'})
    Roqua::Support::Errors.report exception
  end
end