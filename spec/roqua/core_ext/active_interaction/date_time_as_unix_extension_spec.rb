require 'active_interaction'
require 'active_support/all'
require 'roqua/core_ext/active_interaction/filters/date_time_as_unix_extension'

class DateTimeFilterOperation < ActiveInteraction::Base
  date_time :date_time, default: nil

  def execute
    date_time
  end
end

describe RoquaDateTimeAsUnixFilterExtension do
  let(:time) { Time.now.change(:usec => 0) }

  it 'unix integer time translates correctly to datetime' do
    expect(DateTimeFilterOperation.run! date_time: time.to_i).to eq time
  end

  it 'unix integer time as string translates correctly to datetime' do
    expect(DateTimeFilterOperation.run! date_time: time.to_i.to_s).to eq time
  end

  it 'transations and empty string to nil' do
    expect(DateTimeFilterOperation.run! date_time: '').to eq nil
  end
end

class TimeFilterOperation < ActiveInteraction::Base
  time :time, default: nil

  def execute
    time
  end
end

describe RoquaDateTimeAsUnixFilterExtension do
  let(:time) { Time.now.change(:usec => 0) }

  it 'unix integer time translates correctly to time' do
    expect(TimeFilterOperation.run! time: time.to_i).to eq time
  end

  it 'unix integer time as string translates correctly to datetime' do
    expect(TimeFilterOperation.run! time: time.to_i.to_s).to eq time
  end

  it 'transations and empty string to nil' do
    expect(TimeFilterOperation.run! time: '').to eq nil
  end
end
