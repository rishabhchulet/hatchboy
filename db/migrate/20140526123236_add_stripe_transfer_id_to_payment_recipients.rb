class AddStripeTransferIdToPaymentRecipients < ActiveRecord::Migration
  def change
    change_table :payment_recipients do |t|
      t.column :stripe_transfer_id, :string
    end
    add_index :payment_recipients, :stripe_transfer_id
  end
end
