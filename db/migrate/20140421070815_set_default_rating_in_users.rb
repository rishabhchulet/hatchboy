class SetDefaultRatingInUsers < ActiveRecord::Migration
  def up
    change_column :users, :rating, :decimal, :precision => 6, :scale => 2, :null => false, :default => 0.0
  end
  def down
    change_column :users, :rating, :decimal, :precision => 6, :scale => 2
  end
end
