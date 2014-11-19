require 'roqua/support/helpers'

describe 'Helper methods' do
  describe '#with_instrumentation' do
    include Roqua::Support::Helpers

    let(:logger) { double("Logger", info: nil, error: nil) }
    let(:stats)  { double("Stats", increment: nil, measure: nil) }

    before do
      allow(Roqua).to receive(:logger).and_return(logger)
      allow(Roqua).to receive(:stats).and_return(stats)
    end

    context 'when the block returns a value' do
      it 'logs the start and finish lifecycle of a block' do
        expect(logger).to receive(:info).with('testevent:started', {extra: "params"}).ordered
        expect(logger).to receive(:info).with('testevent:finished', hash_including({extra: "params"})).ordered
        expect(stats).to receive(:increment).with('testevent.finished')
        expect(stats).to receive(:measure).with('testevent.duration', an_instance_of(Float))

        with_instrumentation('testevent', extra: 'params') { 1 + 1 }
      end

      it 'returns the value returned by the block' do
        with_instrumentation('testevent') { 1 + 1 }.should == 2
      end
    end

    context 'when an exception happens during the block' do
      it 'logs the start and failure of a block if it raises' do
        expect(logger).to receive(:info).with('testevent:started', instance_of(Hash)).ordered
        expect(logger).to receive(:error).with('testevent:failed', instance_of(Hash)).ordered
        expect(stats).to receive(:increment).with('testevent.failed')

        with_instrumentation 'testevent' do
          raise StandardError, "Foo"
        end rescue nil
      end

      it 'reraises the exception' do
        expect {
          with_instrumentation 'testevent' do
            raise "Foo"
          end
        }.to raise_error('Foo')
      end
    end
  end
end
