class CreateUnsubscribedTeams < ActiveRecord::Migration
  def change
    create_table :unsubscribed_teams do |t|
      t.references :user
      t.references :team
      t.timestamps
    end
  end
end
