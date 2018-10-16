class RenamePaymentSystemColumn < ActiveRecord::Migration
  def change
    rename_column :payment_transactions, :payment_system, :type
  end
end
