class CreatePaymentTransactions < ActiveRecord::Migration
  def change
    create_table :payment_transactions do |t|
      t.integer :payment_id
      t.string :payment_system
      t.string :transaction_id
      t.string :transaction_status

      t.timestamps
    end
  end
end
