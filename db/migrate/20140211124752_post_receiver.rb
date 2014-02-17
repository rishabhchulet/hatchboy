class PostReceiver < ActiveRecord::Migration
  def change
    create_table :post_receivers do |t|
      t.references :post, index: true
      t.references :receiver, polymorphic: true, index: true
      
      t.timestamps
    end    
  end
end
