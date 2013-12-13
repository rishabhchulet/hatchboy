class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.integer :company_id
      t.string  :name
      t.string  :contact_email
      t.string  :role
      t.string  :status

      t.timestamps
    end
  end
end
