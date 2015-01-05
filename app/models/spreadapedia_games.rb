require 'csv'

class SpreadapediaGames < ActiveRecord::Base
  attr_accessible :date, :home, :hscore, :line, :lresult, :ouresult, :overunder, :result, :visitor, :vscore, :week, :vmoneyline, :hmoneyline

  def self.to_csv
    CSV.open("games.export.csv", "wb") do |csv|
      csv << column_names
      all.each do |game|
        csv << game.attributes.values_at(*column_names)
      end
    end
  end

  def line_result(result)
    self.lresult = check_result(self.vscore - self.hscore, -self.line, result)
  end

  def game_result(result)
    self.result = check_result(self.vscore - self.hscore, 0, result)
  end

  def overunder_result(result)
    self.ouresult = check_result(self.vscore + self.hscore, self.overunder, result)
  end

  def check_result(diff, amt, result)
    win = nil
    result.downcase!

    if (("loss" == result) or ("under" == result))
      win = -1
    elsif (("win" == result) or ("over" == result))
      win = 1
    elsif (("tie" == result) or ("even" == result))
      win = 0
    elsif ("not recorded" == result)
      win = nil
    else
      raise "Unknown result: #{date} #{self.visitor} #{self.home} #{vscore} #{hscore} #{diff} #{amt} #{win} #{result}"
    end

    if (nil != win)
      if ((diff > amt) and (1 != win)) or
         ((diff < amt) and (-1 != win)) or
         ((diff == amt) and (0 != win))
        raise "Discrepency: #{date} #{self.visitor}@#{self.home} #{vscore} #{hscore} #{diff} #{amt} #{win} #{result}"
      end
    end

    return win
  end
end
