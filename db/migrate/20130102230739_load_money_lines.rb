require 'open-uri'

class LoadMoneyLines < ActiveRecord::Migration
  def removetd(s)
    gt = s.index('>')
    lt = nil
    
    if (nil != gt)
      lt = s.index('<', gt)
    end

    if (nil != gt)
      if (nil != lt)
        return "#{s[gt+1..lt-1]}"
      else
        return "#{s[gt+1..-1]}"
      end
    else
      return s
    end
  end

  def home?(s)
    return s.include?("At ")
  end

  def team(s)
    return Game.team(s.sub(/At /, ""))
  end

  def spread(s)
    _s = removetd(s)

    if (true == _s.include?("PK"))
      _s = 0
    end

    return BigDecimal.new(_s)
  end

  def update(query, vspread, hline, vline)
    puts "Finding #{query}"
    update_params = {:hline => hline, :vline => vline, :vspread => vspread}
    g = Game.where(query)

    if (nil == g)
      raise "!ERROR: Unable to find game with attributes #{query}"
    elsif (true == g.many?)
      raise "!ERROR: Found more than one record with #{query}"
    end

    if (1 != g.update_all(update_params))
      #raise "!ERROR: Failed to update attributes of #{g} with #{update_params}"
    end
  end

  def up
    (1..18).each do |week|
      year = nil
      query = {}
      favorite = nil
      underdog = nil
      fline    = nil
      uline    = nil
      overunder= nil
      spread   = nil

      if (18 == week)
        page = "http://www.footballlocks.com/nfl_odds.shtml"
        ygrep = "NFL Game Odds"
      else
        page = "http://www.footballlocks.com/nfl_odds_week_#{week}.shtml"
        ygrep = "Closing Las Vegas NFL Odds From Week"
      end

      open(page).each_line do |line|
      #File.open("testfile.txt").each_line do |line|
        line.strip!

        if (true == line.include?(ygrep))
          year = "#{line[-4..-1]}"
        end

        if (nil == query[:date])
          if (nil != line.index(/ \d+:\d\d ET/))
            begin
              date = "#{line.match(/\d+\/\d+/)}/#{year}"
              query[:date] = Date.strptime(date, "%m/%d/%Y")
            rescue
              query[:date] = nil
            end
          end
        else
          if (nil != line.index(/<TD>/))
            tdopen = true
          end

          if (true == tdopen)
            if (nil == favorite)
              favorite = removetd(line)

              begin
                team(favorite)
                tdopen = false
              rescue
                favorite = nil
              end
            elsif (nil == spread)
              spread = spread(line)
              tdopen = false
            elsif (nil == underdog)
              underdog = removetd(line)

              begin
                team(underdog)
                tdopen = false
              rescue
                underdog = nil
              end
            elsif (nil == overunder)
              overunder = 1
              tdopen = false
            elsif (nil == fline)
              fline = "#{line.match(/-\$\d+/)}"
              fline.delete!("$")
              fline.delete!("+")
              uline = "#{line.match(/\+\$\d+/)}"
              uline.delete!("$")
              uline.delete!("+")
              puts "#{query[:date]} #{favorite} #{spread} (#{fline}) OVER #{underdog} (#{uline}) #{overunder}"

              if (true == home?(favorite))
                query[:home]    = team(favorite)
                query[:visitor] = team(underdog)
                update(query, -spread, fline, uline)
              elsif (true == home?(underdog))
                query[:visitor] = team(favorite)
                query[:home]    = team(underdog)
                update(query, spread, uline, fline)
              else
                puts "!ERROR: No home team - #{favorite} vs #{underdog}"
              end

              query.clear
              favorite = nil
              underdog = nil
              fline    = nil
              uline    = nil
              overunder= nil
              spread   = nil
              tdopen   = false
            end
          end
        end
      end
    end
  end

  def down
  end
end
