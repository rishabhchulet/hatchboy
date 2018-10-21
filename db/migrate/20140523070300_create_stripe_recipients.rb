class CreateStripeRecipients < ActiveRecord::Migration
  def change
    create_table :stripe_recipients do |t|
      t.integer :user_id
      t.string :recipient_token
      t.string :last_4_digits

      t.timestamps
    end

    add_index :stripe_recipients, :user_id
  end
end
