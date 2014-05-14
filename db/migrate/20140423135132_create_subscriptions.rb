class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :user
      t.boolean :user_was_added
      t.boolean :user_was_removed
      t.boolean :team_was_added
      t.boolean :team_was_removed
      t.boolean :payment_was_sent
      t.boolean :data_source_was_created
      t.boolean :document_for_signing_was_uploaded

      t.boolean :data_source_added_to_team
      t.boolean :post_added_to_team
      t.boolean :user_added_to_team
      t.boolean :time_log_added_to_team

      t.timestamps
    end
  end
end
