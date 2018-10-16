class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.integer :company_id
      t.string :name
      t.string :type
      t.string :url
      t.string :consumer_key
      t.string :access_token
      t.string :access_token_secret
      t.text   :private_key

      t.timestamps
    end
  end
end
