class AddDocumentWasSigningToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :document_was_signed, :boolean
  end
end
