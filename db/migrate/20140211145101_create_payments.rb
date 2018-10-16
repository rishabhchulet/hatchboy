class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :company_id
      t.integer :created_by_id
      t.string  :status
      t.string  :description
      t.boolean :deleted

      t.timestamps
    end
  end
end
