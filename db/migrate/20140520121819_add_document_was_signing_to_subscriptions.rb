class AddDocumentWasSigningToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :document_was_signing, :boolean
  end
end
