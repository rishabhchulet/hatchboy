class DocuSign < ActiveRecord::Base
  belongs_to :company
  belongs_to :user

  mount_uploader :document, DocumentUploader

  STATUS_PROCESSING = "processing"
  STATUS_SIGNED = "signed"

end
