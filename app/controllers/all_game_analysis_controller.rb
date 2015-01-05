class AllGameAnalysisController < ApplicationController
  def view
    @data = {:headers => AnalysisController::HEADERS, :data => []}

    results = VisitorStats.spreadapedia_games_folded(params)
    #results = VisitorStats.spreadapedia_games(params)

    results.keys.sort.each do |k|
      @data[:data] << results[k].to_html_array
    end

    render(:template => 'analysis/view')
  end
end
