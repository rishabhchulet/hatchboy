class RemoveTypeFromPaymentTransactions < ActiveRecord::Migration
  def up
    remove_column :payment_transactions, :type
  end

  def down
    add_column :payment_transactions, :type, :string
  end
end
