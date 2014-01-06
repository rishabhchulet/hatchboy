class CreateWorkLogs < ActiveRecord::Migration
  def change
    create_table :work_logs do |t|
      t.integer :team_id
      t.integer :source_id
      t.integer :sources_user_id
      t.string  :uid_in_source
      t.string  :issue
      t.date    :on_date
      t.integer :time
      t.string  :comment

      t.timestamps
    end
  end
end
