class AdduserFieldToDocuTemplate < ActiveRecord::Migration
  def change
    add_column :docu_templates, :user_id, :integer
    add_index :docu_templates, ["user_id"], name: "index_docu_templates_on_user_id", using: :btree
  end
end
