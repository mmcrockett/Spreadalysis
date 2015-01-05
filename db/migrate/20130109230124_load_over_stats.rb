class LoadOverStats < ActiveRecord::Migration
  def up
    stats = {}

    SpreadapediaGames.where("date < ? AND date > ?", Date.strptime("08/01/2010", "%m/%d/%Y"), Date.strptime("08/01/1999", "%m/%d/%Y")).each do |game|
      if (false == stats.include?(game.overunder))
        puts "Adding #{game.overunder}"
        stats[game.overunder] = OverStats.new(:over => game.overunder, :games => 0, :overs => 0, :unders => 0)
      end

      stats[game.overunder].games += 1

      if (1 == game.ouresult)
        stats[game.overunder].overs += 1
      elsif (-1 == game.ouresult)
        stats[game.overunder].unders += 1
      end
    end

    stats.each_pair do |k,v|
      puts "Saving: #{k}:#{v}"
      v.save()
    end
  end

  def down
    OverStats.delete_all
  end
end
