class Document < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  mount_uploader :doc_file, FileUploader
end
