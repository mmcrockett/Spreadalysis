class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.date :date, :null => false
      t.string :visitor, :null => false
      t.integer :vscore, :null => false
      t.string :home, :null => false
      t.integer :hscore, :null => false
      t.decimal :vspread, :precision => 4, :scale => 1
      t.decimal :overunder, :precision => 4, :scale => 1, :null => false
      t.integer :vline
      t.integer :hline
    end
  end
end
