class AddMoneyLinesToSpreadapediaGames < ActiveRecord::Migration
  def change
    add_column :spreadapedia_games, :vmoneyline, :integer
    add_column :spreadapedia_games, :hmoneyline, :integer
  end
end
