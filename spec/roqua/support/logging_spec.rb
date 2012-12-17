require 'roqua/support/logging'
require 'logger'
require 'stringio'

module Roqua
  describe LogWrapper do
    let(:logstream)  { StringIO.new }
    let(:logger)     { Logger.new(logstream) }
    let(:logwrapper) { LogWrapper.new(logger) }

    def log
      logstream.string
    end

    describe '#add' do
      it 'writes event name to log' do
        logwrapper.add :info, "testevent"
        log.should include("testevent\n")
      end

      it 'writes given parameters as key=value pairs' do
        logwrapper.add :info, "testevent", extra: 'params', go: 'here'
        log.should include("testevent extra=params go=here\n")
      end

      it 'rounds given float parameters' do
        logwrapper.add :info, "testevent", float: 0.123456789
        log.should include("testevent float=0.1235\n")
      end

      it 'replaces newlines in parameters with spaces' do
        logwrapper.add :info, "testevent", param: "this\nshould not have newlines"
        log.should include("testevent param=this should not have newlines")
      end
    end

    describe '#lifecycle' do
      it 'logs the start and finish lifecycle of a block' do
        logwrapper.lifecycle 'testevent', extra: 'params' do
          1 + 1
        end
        log.should include('testevent:started extra=params')
        log.should match(/testevent:finished.*extra=params/)
      end

      it 'logs the duration of the block with the finished event' do
        logwrapper.lifecycle('testevent') { 1 + 1 }
        log.should match(/testevent:finished.*duration=/)
      end

      it 'returns the value returned by the block' do
        logwrapper.lifecycle('testevent') { 1 + 1 }.should == 2
      end

      it 'logs the start and failure of a block if it raises' do
        logwrapper.lifecycle 'testevent' do
          raise StandardError, "Foo"
        end rescue nil
        log.should include('testevent:started')
        log.should include('testevent:failed exception=StandardError message=Foo')
      end

      it 'reraises the exception' do
        expect { 
          logwrapper.lifecycle 'testevent' do 
            raise "Foo"
          end
        }.to raise_error('Foo')
      end
    end

    describe '.lifecycle' do
      it 'wraps given method' do
        ::Roqua.stub(:logger => logwrapper)

        test = Class.new do
          include Logging
          
          def foo
            'bar'
          end
          log :foo, 'roqua.testevent.foo'
        end

        test.new.foo.should == 'bar'
        log.should include('roqua.testevent.foo:started')
        log.should include('roqua.testevent.foo:finished')
      end
    end
  end
end