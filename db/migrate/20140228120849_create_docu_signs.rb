class CreateDocuSigns < ActiveRecord::Migration
  def change
    create_table :docu_signs do |t|
      t.references :company, index: true
      t.references :user, index: true
      t.references :docu_template, index: true
      t.string :envelope_key
      t.string :status

      t.timestamps
    end
  end
end
