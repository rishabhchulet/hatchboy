class AddAdditionalInfoToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :additional_info, :text
  end
end
