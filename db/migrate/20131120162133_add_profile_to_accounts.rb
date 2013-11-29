class AddProfileToAccounts < ActiveRecord::Migration
  def change
    change_table :accounts do |t|
      t.column :profile_type, :string
      t.column :profile_id, :integer
    end
  end
end
