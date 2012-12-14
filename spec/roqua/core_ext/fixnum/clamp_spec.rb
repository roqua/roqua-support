require 'roqua/core_ext/fixnum/clamp'

describe Fixnum do
  describe '#clamp' do
    it "returns self if within bounds" do
      5.clamp(1,10).should == 5
    end

    it "returns the lower bound if self < low" do
      5.clamp(8,10).should == 8
    end

    it "returns the upper bound if self > high" do
      5.clamp(1,3).should == 3
    end

    it "should raise an exception if the lower bound is greater than the upper bound" do
      expect {
        5.clamp(10,1)
      }.to raise_error
    end
  end
end
