# encoding: utf-8
class FileUploader < BaseUploader
  include CarrierWave::MimeTypes
  include CarrierWave::MiniMagick

  process :set_content_type
  process :save_content_type_and_size_in_model

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{Rails.env}/#{model.class.to_s.underscore}/#{model.owner.class.to_s.underscore}/#{model.owner.id.to_s}/"
  end
  
  def save_content_type_and_size_in_model
    model.doc_type = file.content_type if file.content_type
    model.doc_size = file.size
  end

end
