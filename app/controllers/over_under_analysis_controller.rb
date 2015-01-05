class OverUnderAnalysisController < ApplicationController
  def view
    @data = {:headers => ["OverUnder", "Games", "Over", "Under", "Even", "CONF", "E(x)"], :data => []}
    results = {}
    overunder = 47.5
    type      = :over

    [-1,0,1].each do |result|
      if (:under == type)
        symbol = "<="
      else
        symbol = ">="
      end

      SpreadapediaGames.select("#{overunder} AS line, count(1) AS cnt").where("ouresult = ? AND date < ? AND overunder #{symbol} #{overunder}", result, Date.strptime("08/01/2010", "%m/%d/%Y")).all.each do |g|
      #SpreadapediaGames.select("overunder AS line, count(1) AS cnt").where("ouresult = ? AND date < ?", result, Date.strptime("08/01/2010", "%m/%d/%Y")).group(:overunder).all.each do |g|
        if (nil == results[g.line])
          results[g.line] = VisitorStats.new(:line=>g.line, :games => 0, :atswins => 0, :atslosses => 0, :wins => 0, :losses => 0);
        end

        if (-1 == result)
          results[g.line].atslosses += g.cnt
        elsif (1 == result)
          results[g.line].atswins   += g.cnt
        end

        results[g.line].games += g.cnt
      end
    end

    results.keys.sort.each do |k|
      row = results[k]
      cs = Statsample::Test::ChiSquare::WithMatrix.new(Matrix.rows([row.ats_observed]), Matrix.rows([row.ats_expected]))
      @data[:data] << [row.line, row.games, row.percentage(:ats_win), row.percentage(:ats_loss), row.percentage(:ats_tie), ActionController::Base.helpers.number_to_percentage(cs.probability(), :precision => 2), row.expected_return]
    end
  end
end
