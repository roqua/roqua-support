require 'roqua/core_ext/activerecord/uniq_find_or_create'

module ActiveRecord
  class Base
    def self.find_by(attributes)
    end
  end

  class RecordNotUnique < StandardError
  end
end

describe ActiveRecord::Base do
  describe '#uniq_find_or_create_by' do
    let(:attributes) { double('attributes') }
    let(:block)      { -> {} }
    let(:record)     { double('record') }

    it 'tries to find or create a record by the attributes provided' do
      expect(ActiveRecord::Base).to receive(:find_or_create_by).with(attributes, &block)
      ActiveRecord::Base.uniq_find_or_create_by attributes, &block
    end

    it 'returns a preexisting or created record by querying it' do
      allow(ActiveRecord::Base).to receive(:find_by).with(attributes).and_return record
      expect(ActiveRecord::Base.uniq_find_or_create_by attributes, &block).to eq(record)
    end

    it 'returns a concurrenlty created record' do
      allow(ActiveRecord::Base).to receive(:find_by).with(attributes).and_return record
      allow(ActiveRecord::Base).to receive(:find_or_create_by).with(attributes, &block)
                                                              .and_raise ActiveRecord::RecordNotUnique
      expect(ActiveRecord::Base.uniq_find_or_create_by attributes, &block).to eq(record)
    end

    it 'returns a created record for inspection when saving fails for some reason' do
      allow(ActiveRecord::Base).to receive(:find_or_create_by).with(attributes, &block).and_return record
      expect(ActiveRecord::Base.uniq_find_or_create_by attributes, &block).to eq(record)
    end
  end
end
