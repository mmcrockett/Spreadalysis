class OverStats < ActiveRecord::Base
  attr_accessible :games, :over, :overs, :unders

  def percentage(type)
    if (:over == type)
      numerator = self.overs
    elsif (:under == type)
      numerator = self.unders
    elsif (:even == type)
      numerator = (self.games - self.overs - self.unders)
    else
      raise "Invalid percentage: #{type}"
    end

    return AggregateWinners.percent(numerator, self.games)
  end
end
