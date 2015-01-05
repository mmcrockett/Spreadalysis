require 'csv'

namespace :spreadalysis do
  desc "Export Spreadapedia Database to CSV"
  task(:csv => :environment) do
    SpreadapediaGames.to_csv
  end

  desc "Explore whether total is correlated to over/under."
  task(:scoring_correlation => :environment) do
    YEARS = [2009, 2010, 2011, 2012]

    YEARS.each do |year|
      data = {:total => {:oumiss => 0, :tmiss => 0, :pmiss => 0, :games =>0, :pts => 0}}
      pweek = "1"
      pavg  = 0
      start_date = Date.strptime("#{year}0801", "%Y%m%d")
      end_date   = Date.strptime("#{year+1}0801", "%Y%m%d")
      SpreadapediaGames.where("date > ? AND date < ?", start_date, end_date).order(:date).all.each do |g|
        game_score = (g.vscore + g.hscore)
        exp_score_team = 0
        exp_score = 0

        if (pweek != g.week)
          puts "#{pweek}:#{g.week}:#{pavg}"
          pweek = g.week
          pavg  = (data[:total][:pts]/data[:total][:games]).to_i
        end

        [{:team => g.home, :score => g.hscore},{:team => g.visitor, :score => g.vscore}].each do |d|
          team = d[:team]
          data[team] ||= {}
          data[team][:pts]   ||= 0
          data[team][:games] ||= 0

          if (0 != data[team][:games])
            exp_score_team += (data[team][:pts]/data[team][:games]).to_i
          else
            exp_score_team += d[:score]
          end

          data[team][:pts]   += d[:score]
          data[team][:games] += 1
        end

        data[:total][:oumiss] += (game_score - g.overunder).abs
        data[:total][:pmiss]  += (game_score - exp_score_team).abs
        data[:total][:tmiss]  += (game_score - pavg).abs

        data[:total][:pts]    += game_score
        data[:total][:games]  += 1
      end

      puts "#{year}"
      puts "  OU:"
      puts "    T: #{data[:total][:oumiss]}"
      puts "    A: #{data[:total][:oumiss]/data[:total][:games]}"
      puts "  PM:"
      puts "    T: #{data[:total][:pmiss]}"
      puts "    A: #{data[:total][:pmiss]/data[:total][:games]}"
      puts " ALL:"
      puts "    T: #{data[:total][:tmiss]}"
      puts "    A: #{data[:total][:tmiss]/data[:total][:games]}"
    end
  end
end
