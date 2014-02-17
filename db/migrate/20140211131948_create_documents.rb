class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.references :owner, polymorphic: true, index: true
      t.string :doc_file
      t.string :doc_type
      t.integer :doc_size

      t.timestamps
    end
  end
end
