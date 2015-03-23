require 'spec_helper'
require 'roqua/validators/subset_validator'

describe SubsetValidator do
  let(:validatable) do
    Class.new do
      include ActiveModel::Validations

      attr_accessor :list

      validates :list, subset: {of: [1, 2, 3]}

      def initialize(list)
        self.list = list
      end
    end
  end

  it 'allows nil values' do
    expect(validatable.new(nil)).to be_valid
  end

  it 'allows empty arrays' do
    expect(validatable.new([])).to be_valid
  end

  it 'allows a subset' do
    expect(validatable.new([1])).to be_valid
    expect(validatable.new([1, 2])).to be_valid
  end

  it 'allows exact match to set' do
    expect(validatable.new([1, 2, 3])).to be_valid
  end

  it 'does not allow an element not in the set' do
    expect(validatable.new([1, 2, 100])).not_to be_valid
  end
end
