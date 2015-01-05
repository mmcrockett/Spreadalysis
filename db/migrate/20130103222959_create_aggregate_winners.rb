class CreateAggregateWinners < ActiveRecord::Migration
  def change
    create_table :aggregate_winners do |t|
      t.decimal :vspread
      t.integer :games
      t.integer :wins
      t.integer :losses
      t.integer :winsspread
      t.integer :lossspread
    end
  end
end
