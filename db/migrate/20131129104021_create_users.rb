class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :company_id
      t.string :name
      t.string :contact_email
      t.string :role
      t.string :status
      t.string :avatar

      t.timestamps
    end
  end
end

