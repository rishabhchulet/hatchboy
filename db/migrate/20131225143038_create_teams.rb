class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.integer :company_id
      t.string :name
      t.text :description
      t.integer :created_by_id

      t.timestamps
    end
  end
end
