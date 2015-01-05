class AggregateWinners < ActiveRecord::Base
  attr_accessible :games, :vspread, :wins, :losses, :winsspread, :lossspread

  def percentage(type)
    if (:win == type)
      numerator = self.wins
    elsif (:loss == type)
      numerator = self.losses
    elsif (:tie == type)
      numerator = (self.games - self.losses - self.wins)
    elsif (:ats_win == type)
      numerator = self.winsspread
    elsif (:ats_loss == type)
      numerator = self.lossspread
    elsif (:ats_tie == type)
      numerator = (self.games - self.lossspread - self.winsspread)
    else
      raise "Invalid percentage: #{type}"
    end

    return AggregateWinners.percent(numerator, self.games)
  end

  def self.percent(numerator, denominator)
    wpercentage = BigDecimal.new(numerator)/BigDecimal.new(denominator)*100

    return ActionController::Base.helpers.number_to_percentage(wpercentage, :precision => 2)
  end
end
