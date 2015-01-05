class ReconcileGames < ActiveRecord::Migration
  def up
    Game.where("vline IS NOT NULL AND hline IS NOT NULL").each do |row|
      matching_game = SpreadapediaGames.where(:date => row[:date], :home => row[:home], :visitor => row[:visitor]).first
      diff = matching_game.line - row.vspread

      if (matching_game.vscore != row.vscore) or (matching_game.hscore != row.hscore)
        puts "MISMATCH: #{row.date} #{row.visitor} @ #{row.home} - #{matching_game.vscore}:#{matching_game.hscore} vs #{row.vscore}:#{row.hscore}"
        matching_game.vscore = row.vscore
        matching_game.hscore = row.hscore
        puts "FIXED: #{row.date} #{row.visitor} @ #{row.home} - #{matching_game.vscore}:#{matching_game.hscore} vs #{row.vscore}:#{row.hscore}"
      end

      matching_game.vmoneyline = row.vline
      matching_game.hmoneyline = row.hline

      if (diff != 0)
        puts "MISMATCH: #{row.date} #{row.visitor} @ #{row.home} - #{matching_game.line}:#{row.vspread}"
        visitor_score_diff = row.vscore - row.hscore
        visitor_score_diff_and_spread = visitor_score_diff + row.vspread
        matching_game.line = row.vspread

        if (0 == visitor_score_diff)
          matching_game.game_result("tie")
        elsif (0 < visitor_score_diff)
          matching_game.game_result("win")
        else
          matching_game.game_result("loss")
        end

        if (0 == visitor_score_diff_and_spread)
          matching_game.line_result("tie")
        elsif (0 < visitor_score_diff_and_spread)
          matching_game.line_result("win")
        else
          matching_game.line_result("loss")
        end
        puts "FIXED: #{row.date} #{row.visitor} @ #{row.home} - #{matching_game.line}:#{row.vspread}"
      end
      matching_game.save()
    end
  end

  def down
  end
end
