class DocuTemplate < ActiveRecord::Migration
  def change
    create_table :docu_templates do |t|
      t.references :company, index: true
      t.string :template_key
      t.string :document
      
      t.timestamps
    end
  end
end
