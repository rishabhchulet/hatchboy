class CreateUnsubscribedTeams < ActiveRecord::Migration
  def change
    create_table :unsubscribed_teams do |t|

      t.timestamps
    end
  end
end
