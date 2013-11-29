class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.column :name, :string
      t.column :company_id, :integer
    end
  end
end
