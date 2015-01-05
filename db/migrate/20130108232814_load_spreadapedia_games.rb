require 'json'
require 'open-uri'

class LoadSpreadapediaGames < ActiveRecord::Migration
  def up
    (1980..2012).each do |year|
      page = "http://107.20.201.13/Spreadapedia/NFL/GetAllResults/?queryBuild=year%2Cbetween%2C#{year}a#{year}%3Blocation%2Cvalue%2Caway%3B"
      data = JSON.parse(open(page).read())

      data.each do |row|
        record = SpreadapediaGames.new()
        record.date      = Date.strptime(row[0].strip, "%m/%d/%Y")
        record.week      = row[1].strip
        record.visitor   = row[2].strip
        record.home      = row[3].strip.sub(/at /, "")
        record.line      = row[5].strip
        record.overunder = row[6].strip
        record.vscore    = row[7].strip
        record.hscore    = row[8].strip
        record.line_result(row[13].strip)
        record.game_result(row[14].strip)
        record.overunder_result(row[15].strip)
        record.save()
      end
    end
  end

  def down
    SpreadapediaGames.delete_all
  end
end
