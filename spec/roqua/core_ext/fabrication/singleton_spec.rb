require 'roqua/core_ext/fabrication/singleton'

def Fabricate(name, overrides={}, &block)
  rand
end

describe Fabricate do
  it "returns singleton objects" do
    Fabricate.singleton(:one).should == Fabricate.singleton(:one)
  end

  it 'maintains multiple singletons' do
    Fabricate.singleton(:one).should_not == Fabricate.singleton(:two)
  end
end

