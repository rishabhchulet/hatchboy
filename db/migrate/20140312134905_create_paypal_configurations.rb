class CreatePaypalConfigurations < ActiveRecord::Migration
  def change
    create_table :paypal_configurations do |t|
      t.references :company, index: true
      t.string :login
      t.string :password
      t.string :signature
    end
  end
end
