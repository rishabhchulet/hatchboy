class CreateStripeConfigurations < ActiveRecord::Migration
  def change
    create_table :stripe_configurations do |t|
      t.references :company, index: true
      t.string  :secret_key
      t.string  :public_key
    end
  end
end
