require 'csv'

class StrategyController < ApplicationController
  YEARS = [2010, 2011, 2012]
  VALUE_MINIMUM = 1
  #YEARS = [2010]
  #HISTORICAL = VisitorStats.spreadapedia_games_folded({:end_date => '20100801'})

  def view
    @data = {:headers => ["Year", "Strategy", "Games", "Won", "Lost", "Tie", "Wagers", "Return"], :data => []}
    hspreads = [-9, -7, -5.5, -5, -1.5, 0, 1, 2]
    vspreads = [3, 4.5, -4.5]
    ouoverlimit  = 47.5
    ouunderlimit  = 36
    results  = {}

    YEARS.each do |year|
      results[year] = {}
      start_date = Date.strptime("#{year}0801", "%Y%m%d")
      end_date   = Date.strptime("#{year+1}0801", "%Y%m%d")
      SpreadapediaGames.where("date > ? AND date < ?", start_date, end_date).all.each do |g|
        results[year]["value"]  ||= Wallet.new("value")
        value = determine_value(g)

        if (ouoverlimit <= g.overunder)
          results[year][ouoverlimit] ||= Wallet.new("<= #{ouoverlimit}")
          results[year][ouoverlimit].payout(Wager.new(g).bet(:overunder, :under))
        end

        if (ouunderlimit >= g.overunder)
          results[year][ouunderlimit] ||= Wallet.new(">= #{ouunderlimit}")
          results[year][ouunderlimit].payout(Wager.new(g).bet(:overunder, :over))
        end

        if (true == hspreads.include?(g.line))
          results[year][g.line] ||= Wallet.new("H(#{g.line})")
          results[year][g.line].payout(Wager.new(g).bet(:spread, :home))
        end

        if (true == vspreads.include?(g.line))
          results[year][g.line] ||= Wallet.new("V(#{g.line})")
          results[year][g.line].payout(Wager.new(g).bet(:spread, :visitor))
        end

        if (-10 > g.line)
          results[year][">10"] ||= Wallet.new("+>10")
          results[year][">10"].payout(Wager.new(g).bet(:spread, :home))
        elsif (10 < g.line)
          results[year][">10"] ||= Wallet.new("+>10")
          results[year][">10"].payout(Wager.new(g).bet(:spread, :visitor))
        end

        if (false == value.empty?)
          results[year]["value"].payout(Wager.new(g).bet(:moneyline, value[:mlteam]))
        end
      end
    end

    if (params[:all])
      aggregate = {}
      results[YEARS[0]].keys.each do |wkey|
        results.keys.sort.each do |year|
          if (nil != results[year][wkey])
            if (false == aggregate.include?(wkey))
              aggregate[wkey] = results[year][wkey]
            else
              aggregate[wkey] += results[year][wkey]
            end
          end
        end
      end

      aggregate.values.each do |v|
        @data[:data] << ["All"] + v.to_html_array
      end
    else
      results[YEARS[0]].keys.each do |wkey|
        results.keys.sort.each do |year|
          if (nil == results[year][wkey])
            @data[:data] << [year, "n/a", "n/a", "n/a", "n/a", "n/a", "n/a", "n/a"]
          else
            @data[:data] << [year] + results[year][wkey].to_html_array
          end
        end
      end
    end
  end

  def value
    @data = {:headers => ["Line", "Strategy", "Games", "Won", "Lost", "Tie", "Wagers", "Return"], :data => []}
    results  = {}
    differentials = {}

    YEARS.each do |year|
      start_date = Date.strptime("#{year}0801", "%Y%m%d")
      end_date   = Date.strptime("#{year+1}0801", "%Y%m%d")
      SpreadapediaGames.where("date > ? AND date < ?", start_date, end_date).all.each do |g|
        value = determine_value(g)

        if (false == value.empty?)
          line = value[:line]
          results[line] ||= Wallet.new("#{line}")
          differentials[line] ||= 0
          differentials[line] += value[:diff]

          results[line].payout(Wager.new(g).bet(:moneyline, value[:mlteam]))
        end
      end
    end

    results.keys.sort.each do |line|
      if (nil == results[line])
        @data[:data] << [line, "n/a", "n/a", "n/a", "n/a", "n/a", "n/a", "n/a"]
      else
        @data[:data] << [BigDecimal.new(differentials[line]/results[line].games).truncate(0)] + results[line].to_html_array
      end
    end

    render(:template => 'strategy/view')
  end

  def value_expanded
    @data = {:headers => ["Date", "Line", "E(ML)", "Home", "D(H)", "Vis", "D(V)", "E(X)"], :data => []}

    YEARS.each do |year|
      start_date = Date.strptime("#{year}0801", "%Y%m%d")
      end_date   = Date.strptime("#{year+1}0801", "%Y%m%d")
      SpreadapediaGames.where("date > ? AND date < ?", start_date, end_date).all.each do |g|
        value = determine_value(g)

        if (false == value.empty?)
          @data[:data] << [g.date, g.line, value[:emoneyline], g.hmoneyline, value[:hdiff], g.vmoneyline, value[:vdiff], Wager.new(g).bet(:moneyline, value[:mlteam])]
          #line = value[:line]
          #results[line] ||= Wallet.new("#{line}")
          #differentials[line] ||= 0
          #differentials[line] += value[:diff]

          #results[line].payout(Wager.new(g).bet(:moneyline, value[:mlteam]))
        end
      end
    end

    render(:template => 'strategy/view')
  end

  def determine_value(g)
    value = {}
    line   = g.line.abs

    #if (line > VisitorStats::FOLDED_MAX)
      #visitor_stat = HISTORICAL[VisitorStats::FOLDED_MAX_KEY]
    #else
      #visitor_stat = HISTORICAL[line]
    #end
    visitor_stat = SpreadOdds.new(line)

    if (nil != visitor_stat)
      vdiff = visitor_stat.ml_diff(g.vmoneyline)
      hdiff = visitor_stat.ml_diff(g.hmoneyline)

      if (VALUE_MINIMUM < vdiff)
        value[:mlteam] = :visitor
        value[:moneyline] = g.vmoneyline
      elsif (VALUE_MINIMUM < hdiff)
        value[:mlteam] = :home
        value[:moneyline] = g.hmoneyline
      end

      if (true == value.include?(:mlteam))
        value[:diff] = visitor_stat.ml_diff(value[:moneyline])
        value[:line] = line
        value[:emoneyline] = visitor_stat.expected_moneyline()
        value[:vdiff] = vdiff
        value[:hdiff] = hdiff
      end
    end

    return value
  end
end
