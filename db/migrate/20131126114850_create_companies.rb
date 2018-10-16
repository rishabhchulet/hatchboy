class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.text :description
      t.integer :created_by_id
      t.integer :contact_person_id

      t.timestamps
    end
    
    add_index :companies, :created_by_id
    add_index :companies, :contact_person_id
  end
end
