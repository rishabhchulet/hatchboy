class AddUserToAccounts < ActiveRecord::Migration
  def change
    change_table :accounts do |t|
      t.column :user_id, :integer
    end
  end
end

