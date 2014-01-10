class CreateSourcesUsers < ActiveRecord::Migration
  def change
    create_table :sources_users do |t|
      t.integer :source_id
      t.string  :name
      t.string  :email
      t.integer :employee_id

      t.timestamps
    end
  end
end
