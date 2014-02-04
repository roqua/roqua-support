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
    stub_const("Airbrake", double("Airbrake", is_ignored_exception?: false))
    Airbrake.should_receive(:notify_or_ignore).with(exception, parameters: {})
    Roqua::Support::Errors.report exception
  end

  context 'when Appsignal is loaded' do
    let(:agent)       { double("agent") }
    let(:transaction) { double("transaction") }

    it 'sends notifications to appsignal' do
      stub_const("Appsignal", Module.new)
      Appsignal.stub(is_ignored_exception?: false, agent: agent)
      stub_const("Appsignal::Transaction", double("Transaction", create: transaction))

      transaction.should_receive(:set_tags).with({})
      transaction.should_receive(:add_exception).with(exception)
      transaction.should_receive(:complete!)
      agent.should_receive(:send_queue)
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