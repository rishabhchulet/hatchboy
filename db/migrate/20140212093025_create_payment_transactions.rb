class CreatePaymentTransactions < ActiveRecord::Migration
  def change
    create_table :payment_transactions do |t|
      t.integer :payment_id
      t.string :payment_system
      t.string :status
      t.text :info

      t.timestamps
    end
  end
end
