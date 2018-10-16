class CreateSourcesUsers < ActiveRecord::Migration
  def change
    create_table :sources_users do |t|
      t.integer :source_id
      t.integer :user_id
      t.string  :uid
      t.timestamps
    end
  end
end

