class VisitorStats < ActiveRecord::Base
  attr_accessible :atslosses, :atswins, :games, :line, :losses, :wins

  ATS_TIE_PERCENT  = 0.0288
  ATS_WIN_PERCENT  = (1 - ATS_TIE_PERCENT)/2
  ATS_LOSS_PERCENT = (1 - ATS_TIE_PERCENT - ATS_WIN_PERCENT)

  WEIGHTED_LIMIT_UNDERDOG = 60
  WEIGHTED_LIMIT_FAVORITE = 100 - WEIGHTED_LIMIT_UNDERDOG

  FOLDED_MAX = 14
  FOLDED_MAX_KEY = FOLDED_MAX + 0.5

  def self.to_csv
    CSV.open("visitor_stats.export.csv", "wb") do |csv|
      csv << ["Line", "Games", "Wins", "Losses", "Win%", "E(ML)"]
      VisitorStats.spreadapedia_games_folded.values.each do |v|
        csv << [v.line, v.games, v.wins, v.losses, v.winp, v.expected_moneyline]
      end
    end
  end

  def +(vs)
    return VisitorStats.new(:games => self.games + vs.games, :wins => self.wins + vs.wins, :losses => self.losses + vs.losses, :atslosses => self.atslosses + vs.atslosses, :atswins => self.atswins + vs.atswins, :line => self.line)
  end

  def -@
    return VisitorStats.new(:games => self.games, :wins => self.losses, :losses => self.wins, :atslosses => self.atswins, :atswins => self.atslosses, :line => self.line)
  end

  def ml_diff(ml)
    if ((nil == ml) or (nil == self.expected_moneyline))
      return -999
    end

    ml = BigDecimal.new(ml)

    if (ml > 0)
      diff = ml - self.expected_moneyline
    else
      diff = self.expected_moneyline - ml.abs
    end

    return diff
  end

  def weighted_ml_diff(ml, team)
    if (nil == ml)
      return -999
    end

    diff = self.ml_diff(BigDecimal.new(ml))
    win_percent = nil

    if (:home == team)
      win_percent = self.lossp
    elsif (:visitor == team)
      win_percent = self.winp
    else
      raise "!ERROR: Unknown team in weighted moneyline diff: #{team}"
    end

    if ((0 < ml) and (win_percent > WEIGHTED_LIMIT_UNDERDOG)) or
       ((0 > ml) and (win_percent < WEIGHTED_LIMIT_FAVORITE))
       raise "!WARNING: Suspicious favorite/underdog ml:#{ml} w%:#{win_percent} line:#{self.line}"
    end

    return ((diff*win_percent)/100).truncate(0)
  end

  def winp
    return BigDecimal(self.percentage(:win))
  end

  def lossp
    return BigDecimal(self.percentage(:loss))
  end

  def expected_moneyline
    ml   = 0

    if ((0 == self.winp) or (0 == self.lossp))
      return nil
    end

    if (self.winp >= 50)
      ml = (100*self.winp/(100-self.winp))
    else
      ml = (100*(100-self.winp)/self.winp)
    end

    return ml.truncate(0)
  end

  def atsties
    return (self.games - self.atswins - self.atslosses)
  end

  def ties
    return (self.games - self.wins - self.losses)
  end

  def ats_observed
    return [self.atswins, self.atslosses, self.atsties]
  end

  def ats_expected
    return [ATS_WIN_PERCENT*self.games, ATS_LOSS_PERCENT*self.games, ATS_TIE_PERCENT*self.games]
  end

  def percentage(type)
    if (:win == type)
      numerator = self.wins
    elsif (:loss == type)
      numerator = self.losses
    elsif (:tie == type)
      numerator = self.ties
    elsif (:ats_win == type)
      numerator = self.atswins
    elsif (:ats_loss == type)
      numerator = self.atslosses
    elsif (:ats_tie == type)
      numerator = self.atsties
    else
      raise "Invalid percentage: #{type}"
    end

    return AggregateWinners.percent(numerator, self.games)
  end

  def to_s
    puts "#{self.line} | #{self.games} | #{self.wins} #{self.losses} #{self.ties} | #{self.atswins} #{self.atslosses} #{self.atsties}"
  end

  def expected_return
    winp = BigDecimal(self.percentage(:ats_win))
    lossp = BigDecimal(self.percentage(:ats_loss))

    if (winp >= lossp)
      return (-110 * lossp + 100 * winp)
    else
      return (-110 * winp + 100 * lossp)
    end
  end

  def to_html_array
    cs = Statsample::Test::ChiSquare::WithMatrix.new(Matrix.rows([self.ats_observed]), Matrix.rows([self.ats_expected]))
    return [self.line, self.games, self.percentage(:win), self.percentage(:loss), self.percentage(:tie), self.percentage(:ats_win), self.percentage(:ats_loss), self.percentage(:ats_tie), ActionController::Base.helpers.number_to_percentage(cs.probability(), :precision => 2), self.expected_return]
  end

  def self.spreadapedia_games(params={})
    results = {}
    start_date = Date.strptime("19700101", "%Y%m%d")
    end_date   = Date.strptime("20100801", "%Y%m%d")

    if (nil != params[:start_date])
      start_date = Date.strptime(params[:start_date], "%Y%m%d")
    end

    if (nil != params[:end_date])
      end_date = Date.strptime(params[:end_date], "%Y%m%d")
    end

    [-1,0,1].each do |result|
      ["result", "lresult"].each do |type|
        SpreadapediaGames.select("line, count(1) AS cnt").where("#{type} = ? AND date > ? AND date < ?", result, start_date, end_date).group(:line).all.each do |g|
          if (nil == results[g.line])
            results[g.line] = VisitorStats.new(:line=>g.line, :games => 0, :atswins => 0, :atslosses => 0, :wins => 0, :losses => 0);
          end

          if (-1 == result)
            if ("result" == type)
              results[g.line].losses += g.cnt
            else
              results[g.line].atslosses += g.cnt
            end
          elsif (1 == result)
            if ("result" == type)
              results[g.line].wins   += g.cnt
            else
              results[g.line].atswins += g.cnt
            end
          end

          if ("result" == type)
            results[g.line].games += g.cnt
          end
        end
      end
    end

    return results
  end

  def self.spreadapedia_games_folded(params = {})
    results = VisitorStats.spreadapedia_games(params)
    folded  = {}

    results.keys.each do |k|
      if (FOLDED_MAX < k.abs)
        new_key = FOLDED_MAX_KEY
      else
        new_key = k.abs
      end

      if (k < 0)
        vs = -results[k]
      else
        vs = results[k]
      end

      if (false == folded.include?(new_key))
        folded[new_key] = vs
      else
        folded[new_key] += vs
      end

      folded[new_key].line = new_key
    end

    return folded
  end
end
