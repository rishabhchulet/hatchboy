class CreateUserAvgRatings < ActiveRecord::Migration
  def change
    create_table :user_avg_ratings do |t|
      t.integer :rated_id
      t.integer :rater_id
      t.float   :avg_score
      t.date    :date_period

      t.timestamps
    end
    add_index :user_avg_ratings, :rated_id
    add_index :user_avg_ratings, :rater_id
    add_index :user_avg_ratings, [:rated_id, :date_period]
    add_index :user_avg_ratings, [:rater_id, :date_period]
  end
end