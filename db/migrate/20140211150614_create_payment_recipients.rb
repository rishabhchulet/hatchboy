class CreatePaymentRecipients < ActiveRecord::Migration
  def change
    create_table :payment_recipients do |t|
      t.integer :payment_id
      t.integer :user_id
      t.float :amount
    end
  end
end
