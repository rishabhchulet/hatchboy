class SetDefaultRatingInUsers < ActiveRecord::Migration
  def change
    change_column :users, :rating, :decimal, :precision => 6, :scale => 2, :null => false, :default => 0.0
  end
end
