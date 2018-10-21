class AddConsumerSecretToSources < ActiveRecord::Migration
  def change
    add_column :sources, :consumer_secret, :string, after: :consumer_key
  end
end
