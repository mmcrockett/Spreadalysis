require 'matrix'
require 'statsample'

class AnalysisController < ApplicationController
  HEADERS = ["Line", "Games", "Win", "Loss", "Tie", "ATS-W", "ATS-L", "ATS-T", "CONF", "E(x)"]

  def view
    favcutoff = -12.5
    udogcutoff = 12.5
    @data = {:headers => HEADERS, :data => []}
    cumulative = nil

    cumulative = VisitorStats.select("max(line) as line, sum(games) as games, sum(wins) as wins, sum(losses) as losses, sum(atswins) as atswins, sum(atslosses) as atslosses").where("line <= ?", favcutoff).order(:line).all
    cumulative += VisitorStats.where("line < ? AND line > ?", udogcutoff, favcutoff).order(:line).all
    cumulative += VisitorStats.select("min(line) as line, sum(games) as games, sum(wins) as wins, sum(losses) as losses, sum(atswins) as atswins, sum(atslosses) as atslosses").where("line >= ?", udogcutoff).order(:line).all

    cumulative.each do |row|
      @data[:data] << row.to_html_array
    end
  end
end
