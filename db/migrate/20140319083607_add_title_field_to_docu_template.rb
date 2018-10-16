class AddTitleFieldToDocuTemplate < ActiveRecord::Migration
  def change
    add_column :docu_templates, :title, :string
  end
end
