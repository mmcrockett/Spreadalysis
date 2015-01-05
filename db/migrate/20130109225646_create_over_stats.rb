class CreateOverStats < ActiveRecord::Migration
  def change
    create_table :over_stats do |t|
      t.integer :games, :null => false
      t.decimal :over, :precision => 4, :scale => 1, :null => false
      t.integer :overs, :null => false
      t.integer :unders, :null => false
    end
  end
end
