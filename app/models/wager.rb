class Wager
  OVER  = 1
  UNDER = -1
  EVEN  = 0

  WIN   = 1
  LOSS  = -1
  TIE   = 0

  AMT   = 100

  def initialize(game)
    if (SpreadapediaGames != game.class)
      raise "!ERROR: Expected #{SpreadapediaGames.class} class and got #{game.class}"
    end
    @game = game
  end

  def bet(type, bet, amt=AMT)
    if (:moneyline == type)
      return self.moneyline(bet, amt)
    elsif (:spread == type)
      return self.spread(bet, amt)
    elsif (:overunder == type)
      return self.overunder(bet, amt)
    else
      raise "!ERROR: Unknown type of bet #{type}"
    end
  end

  def moneyline(bet, amt)
    if (nil == @game.vmoneyline) or (nil == @game.hmoneyline)
      raise "!ERROR: No moneyline for this game: #{@game.id}"
    end

    if (TIE == @game.result)
      return push(amt)
    elsif ((WIN == @game.result) and (:home == bet))
      return lose(amt)
    elsif ((WIN == @game.result) and (:visitor == bet))
      return win(amt, @game.vmoneyline)
    elsif ((LOSS == @game.result) and (:home == bet))
      return win(amt, @game.hmoneyline)
    elsif ((LOSS == @game.result) and (:visitor == bet))
      return lose(amt)
    else
      raise "!ERROR: MoneyLine Bet Failed: #{@game.id} #{@game.result} #{bet}"
    end
  end

  def spread(bet, amt)
    if (TIE == @game.lresult)
      return push(amt)
    elsif ((WIN == @game.lresult) and (:home == bet))
      return lose(amt)
    elsif ((WIN == @game.lresult) and (:visitor == bet))
      return win(amt)
    elsif ((LOSS == @game.lresult) and (:home == bet))
      return win(amt)
    elsif ((LOSS == @game.lresult) and (:visitor == bet))
      return lose(amt)
    else
      raise "!ERROR: Spread Bet Failed: #{@game.id} #{@game.lresult} #{bet}"
    end
  end

  def overunder(bet, amt)
    if (EVEN == @game.ouresult)
      return push(amt)
    elsif ((OVER == @game.ouresult) and (:over == bet))
      return win(amt)
    elsif ((OVER == @game.ouresult) and (:under == bet))
      return lose(amt)
    elsif ((UNDER == @game.ouresult) and (:over == bet))
      return lose(amt)
    elsif ((UNDER == @game.ouresult) and (:under == bet))
      return win(amt)
    else
      raise "!ERROR: Over/Under Bet Failed: #{@game.id} #{@game.ouresult} #{bet}"
    end
  end

  def win(amt, odds=-110)
    if (odds < -100)
      return (BigDecimal.new(amt*100)/BigDecimal.new(odds)).abs.truncate(2)
    elsif (odds > 100)
      return (BigDecimal.new(odds*amt)/BigDecimal.new(100)).abs.truncate(2)
    else
      raise "!ERROR: Odd odds #{@game.id} #{odds}"
    end
  end

  def lose(amt)
    return BigDecimal.new(-amt).truncate(2)
  end

  def push(amt)
    return 0
  end
end
