# Extends Time class.
#
class Time
  def to_ms
    (self.to_f * 1000.0).to_i
  end

  def self.from_ms(ms)
    ms = ms.to_i if ms.is_a? String
    Time.at((ms / 1000).to_i)
  end
end

class ActiveSupport::TimeWithZone
  def to_ms
    (self.to_f * 1000.0).to_i
  end
end
