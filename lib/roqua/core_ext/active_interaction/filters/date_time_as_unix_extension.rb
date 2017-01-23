# allow datetimes to be given as unix times for activeinteractions
module RoquaDateTimeAsUnixFilterExtension
  def cast(value, interaction)
    case value
    when Numeric, /^[0-9]+$/
      Time.at(value.to_i).to_datetime
    when ''
      super(nil, interaction)
    else
      super
    end
  end
end
ActiveInteraction::DateTimeFilter.include RoquaDateTimeAsUnixFilterExtension

# allow datetimes to be given as unix times as string
module RoquaTimeAsUnixFilterExtension
  def cast(value, interaction)
    case value
    when /^[0-9]+$/
      Time.at(value.to_i)
    when ''
      super(nil, interaction)
    else
      super
    end
  end
end
ActiveInteraction::TimeFilter.include RoquaTimeAsUnixFilterExtension
