class AddPaymentInformationToAccounts < ActiveRecord::Migration
  def change
    change_table :accounts do |t|
      t.column :payment_information, :text
    end
  end
end
