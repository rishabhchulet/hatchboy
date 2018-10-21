class RemoveStatusFromPaymentsTransactions < ActiveRecord::Migration

  def up
    remove_column :payment_transactions, :status
  end

  def down
    add_column :payment_transactions, :status, :string
  end

end
