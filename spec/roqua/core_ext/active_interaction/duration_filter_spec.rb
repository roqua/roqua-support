require 'active_interaction'
require 'active_support/all'
require 'roqua/core_ext/active_interaction/filters/duration_filter'

class DurationFilterOperation < ActiveInteraction::Base
  duration :duration
  duration :stripped_duration, strip: true, default: nil

  def execute
    {duration: duration, stripped_duration: stripped_duration}
  end
end

describe ActiveInteraction::DurationFilter do
  let(:duration) { 1.week }
  let(:stripped_duration) { 1.week }


  subject { DurationFilterOperation.run!(duration: duration, stripped_duration: stripped_duration) }

  describe 'when given a duration object' do
    it 'receives the object correctly' do
      expect(subject[:duration]).to be_a(ActiveSupport::Duration)
      expect(subject[:duration]).to eq 1.week
    end

    it 'does not strip non-0 values' do
      expect(subject[:stripped_duration]).to be_a(ActiveSupport::Duration)
      expect(subject[:stripped_duration]).to eq 1.week
    end
  end

  describe 'when given a 0 duration object' do
    let(:duration) { 0.weeks }
    let(:stripped_duration) { 0.weeks }

    it 'receives the object correctly' do
      expect(subject[:duration]).to be_a(ActiveSupport::Duration)
      expect(subject[:duration]).to eq 0.weeks
    end

    it 'strips 0 values' do
      expect(subject[:stripped_duration]).to eq nil
    end
  end

  describe 'when given a hash object' do
    let(:duration) { {value: '1', unit: 'weeks'} }
    let(:stripped_duration) { {value: '1', unit: 'weeks'} }

    it 'receives the object correctly' do
      expect(subject[:duration]).to be_a(ActiveSupport::Duration)
      expect(subject[:duration]).to eq 1.week
    end

    it 'does not strip non-0 values' do
      expect(subject[:stripped_duration]).to be_a(ActiveSupport::Duration)
      expect(subject[:stripped_duration]).to eq 1.week
    end
  end

  describe 'when given a hash {value: "0"} object' do
    let(:duration) { {value: '0', unit: 'weeks'} }
    let(:stripped_duration) { {value: '0', unit: 'weeks'} }

    it 'receives the object correctly' do
      expect(subject[:duration]).to be_a(ActiveSupport::Duration)
      expect(subject[:duration]).to eq 0.weeks
    end

    it 'strips 0 values' do
      expect(subject[:stripped_duration]).to eq nil
    end
  end

  describe 'when given a hash {value: ""} object' do
    let(:duration) { {value: '', unit: 'weeks'} }

    it 'throws a required error when not stripped' do
      expect { subject }.to raise_error ActiveInteraction::InvalidInteractionError, 'Duration is required'
    end
  end

  describe 'when given a hash {value: ""} object' do
    let(:stripped_duration) { {value: '', unit: 'weeks'} }
    it 'strips 0 values' do
      expect(subject[:stripped_duration]).to eq nil
    end
  end
end
