class CreateVisitorStats < ActiveRecord::Migration
  def change
    create_table :visitor_stats do |t|
      t.integer :games, :null => false
      t.decimal :line, :precision => 4, :scale => 1, :null => false
      t.integer :wins, :null => false
      t.integer :losses, :null => false
      t.integer :atswins, :null => false
      t.integer :atslosses, :null => false
    end
  end
end
