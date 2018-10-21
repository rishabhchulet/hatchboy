class AddTypeToPayments < ActiveRecord::Migration
  def up
    add_column :payments, :type, :string
  end

  def down
    remove_column :payments, :type
  end
end
