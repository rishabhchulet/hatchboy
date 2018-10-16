class AddRatingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :rating, :decimal, :precision => 6, :scale => 2
  end
end