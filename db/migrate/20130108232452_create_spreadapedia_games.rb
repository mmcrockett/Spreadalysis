class CreateSpreadapediaGames < ActiveRecord::Migration
  def change
    create_table :spreadapedia_games do |t|
      t.date :date, :null => false
      t.string :week, :null => false
      t.string :visitor, :null => false
      t.string :home, :null => false
      t.decimal :line, :precision => 4, :scale => 1, :null => false
      t.decimal :overunder, :precision => 4, :scale => 1, :null => false
      t.integer :vscore, :null => false
      t.integer :hscore, :null => false
      t.integer :lresult, :null => false
      t.integer :result, :null => false
      t.integer :ouresult
    end
  end
end
