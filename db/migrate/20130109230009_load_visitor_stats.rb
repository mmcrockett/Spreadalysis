class LoadVisitorStats < ActiveRecord::Migration
  def up
    stats = {}

    SpreadapediaGames.where("date < ? AND date > ?", Date.strptime("08/01/2010", "%m/%d/%Y"), Date.strptime("08/01/1999", "%m/%d/%Y")).each do |game|
      if (false == stats.include?(game.line))
        puts "Adding #{game.line}"
        stats[game.line] = VisitorStats.new(:line => game.line, :games => 0, :wins => 0, :losses => 0, :atswins => 0, :atslosses => 0)
      end

      stats[game.line].games += 1

      if (1 == game.lresult)
        stats[game.line].atswins += 1
      elsif (-1 == game.lresult)
        stats[game.line].atslosses += 1
      end

      if (1 == game.result)
        stats[game.line].wins += 1
      elsif (-1 == game.result)
        stats[game.line].losses += 1
      end
    end

    stats.each_pair do |k,v|
      puts "Saving: #{k}:#{v}"
      v.save()
    end
  end

  def down
    VisitorStats.delete_all
  end
end
