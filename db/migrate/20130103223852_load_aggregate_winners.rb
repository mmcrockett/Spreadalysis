class LoadAggregateWinners < ActiveRecord::Migration
  def up
    stats = {}
    Game.where("vspread IS NOT NULL AND date < ?", Date.strptime("08/01/2012", "%m/%d/%Y")).each do |game|
      visitor_spread = game[:vspread]
      visitor_score_difference = game[:vscore] - game[:hscore]

      if (nil == stats[visitor_spread])
        stats[visitor_spread] = AggregateWinners.new(:games => 0, :vspread => visitor_spread, :wins => 0, :losses => 0, :winsspread => 0, :lossspread => 0)
      end

      if (0 < visitor_score_difference)
        stats[visitor_spread].wins += 1
      elsif (0 > visitor_score_difference)
        stats[visitor_spread].losses += 1
      end

      stats[visitor_spread].games += 1

      if (0 < (visitor_score_difference + visitor_spread))
        stats[visitor_spread].winsspread += 1
      elsif (0 > (visitor_score_difference + visitor_spread))
        stats[visitor_spread].lossspread += 1
      end
    end

    stats.each_pair do |k,v|
      v.save()
    end
  end

  def down
    AggregateWinners.delete_all
  end
end
