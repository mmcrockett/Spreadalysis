require 'csv'

class LoadGames < ActiveRecord::Migration
  def up
    Dir["#{ENV['PWD']}/db/historical/*.csv"].each do |file|
      CSV.foreach(file, :headers => true) do |row|
        date = Date.strptime(row['Date'], "%m/%d/%Y")
        puts "Inserting #{date}: #{Game.team(row['Visitor'])} @ #{Game.team(row['Home Team'])}"
        Game.create(:date => date,
                    :home => Game.team(row['Home Team']),
                    :visitor => Game.team(row['Visitor']),
                    :hscore => row['Home Score'],
                    :vscore => row['Visitor Score'],
                    #:vspread  => row['Line'],
                    :overunder => row['Total Line']
                   )
      end
    end
  end

  def down
  end
end
