class Wallet
  attr_reader :name, :money, :wins, :losses, :games, :wagers

  def +(w)
    @money += w.money
    @wins  += w.wins
    @losses += w.losses
    @games  += w.games
    @wagers += w.wagers

    return self
  end

  def initialize(name)
    @name = name
    @money = 0
    @wins = 0
    @losses = 0
    @games = 0
    @wagers = 0
  end

  def bet(amt)
    @wagers += amt
  end

  def payout(amt, wagered=Wager::AMT)
    @games += 1
    @wagers += wagered

    if (0 > amt)
      @losses += 1
    elsif (0 < amt)
      @wins += 1
    end

    @money += amt
  end
  
  def ties
    return self.games - self.wins - self.losses
  end

  def to_html_array
    return [self.name, self.games, self.wins, self.losses, self.ties, ActionController::Base.helpers.number_to_currency(self.wagers), ActionController::Base.helpers.number_to_currency(self.money)]
  end
end
