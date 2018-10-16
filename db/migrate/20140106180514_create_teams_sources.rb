class CreateTeamsSources < ActiveRecord::Migration
  def change
    create_table :teams_sources do |t|
      t.integer :team_id
      t.integer :source_id
      t.string  :uid
      t.timestamps
    end
  end
end
