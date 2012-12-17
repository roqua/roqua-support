require 'roqua/core_ext/enumerable/sort_by_alphanum'

describe Enumerable do
  describe '#sort_by_alphanum' do
    it 'sorts by chunks' do
      ["004some11thing",
       "004some10thing",
       "3another"].sort_by_alphanum.should == ["3another", "004some10thing", "004some11thing"]
    end

    it 'can take a block which can transform values before comparison' do
      ["004some11thing",
       "004some10thing",
       "3another"].sort_by_alphanum(&:reverse).should == ["004some10thing", "004some11thing", "3another"]
    end

    it 'compares number chunks as integers' do
      %w(004 3).sort_by_alphanum.should == %w(3 004)
    end
  end
end