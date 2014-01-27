require 'roqua/support'

describe Roqua do
  describe '#logger' do
    it 'has a default' do
      Roqua.logger.should be_an_instance_of(Roqua::LogWrapper)
    end
  end

  describe '#logger=' do
    let(:logger) { double }

    it 'wraps a given logger' do
      Roqua.logger = logger
      Roqua.logger.should be_an_instance_of(Roqua::LogWrapper)
      Roqua.logger.logger.should == logger
    end
  end
end
