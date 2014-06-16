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

  it 'clears singletons' do
    the_one = Fabricate.singleton(:one)
    Fabricate.clear_singletons!
    expect(Fabricate.singleton(:one)).not_to eq(the_one)
  end
end

