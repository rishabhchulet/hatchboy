class AddFileFieldToDocuSign < ActiveRecord::Migration
  def change
    add_column :docu_signs, :document, :string
  end
end
