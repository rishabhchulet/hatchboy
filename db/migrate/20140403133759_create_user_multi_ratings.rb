class CreateUserMultiRatings < ActiveRecord::Migration
  def change
    create_table :user_multi_ratings do |t|
      t.integer :rated_id
      t.integer :rater_id
      t.integer :score
      t.string  :aspect_code
      t.date    :date_period

      t.timestamps
    end
    add_index :user_multi_ratings, :rated_id
    add_index :user_multi_ratings, :rater_id
    add_index :user_multi_ratings, [:rated_id, :date_period]
    add_index :user_multi_ratings, [:rater_id, :date_period]
  end
end