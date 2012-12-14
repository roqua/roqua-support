class Fixnum
  def clamp(low, high)
    raise "Low (#{low}) must be lower than high (#{high})" unless low < high
    return low if self < low
    return high if self > high
    self
  end
end