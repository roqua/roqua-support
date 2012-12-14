require 'roqua/core_ext/array/stable_sort_by'

describe Array do
  describe "#stable_sort_by" do
    it "wraps #sort" do
      array = []
      array.should_receive(:sort)
      array.stable_sort_by
    end

    it "sorts nil values before all others" do
      [1, nil, 3].stable_sort_by.should == [nil, 1, 3]
    end

    it "defaults to regular comparison" do
      [1, 3, 2].stable_sort_by.should == [1, 2, 3]
    end

    it "accepts a block to do complex comparison" do
      [{a: 2, b: 2, c: 3},
       {a: 2, b: 2, c: 4},
       {a: 1, b: 1, c: 6}].stable_sort_by do |x, y|
        [x[:a], x[:b], x[:c]] <=> [y[:a], y[:b], y[:c]]
       end.should == [{a: 1, b: 1, c: 6},
                      {a: 2, b: 2, c: 3},
                      {a: 2, b: 2, c: 4}]
    end

    it "leaves items in original order if they are the same" do
      [{a: 2, b: 2, c: 4},
       {a: 2, b: 1, c: 3},
       {a: 1, b: 3, c: 6}].sort do |x, y|
        [x[:a], x[:b]] <=> [y[:a], y[:b]]
       end.should == [{a: 1, b: 3, c: 6},
                      {a: 2, b: 1, c: 3},
                      {a: 2, b: 2, c: 4}]

    end
  end
end
