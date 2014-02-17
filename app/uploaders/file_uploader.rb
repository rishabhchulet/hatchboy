# encoding: utf-8
require 'carrierwave/processing/mime_types'

class FileUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes
  include CarrierWave::MiniMagick

  process :set_content_type
  process :save_content_type_and_size_in_model

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{Rails.env}/#{model.class.to_s.underscore}/#{model.owner.class.to_s.underscore}/#{model.owner.id.to_s}/"
  end
  
  def root
    Rails.root.to_s + '/public/'
  end
=begin
  def filename
    secure_token if super
  end
  
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    new_token = ["#{SecureRandom.hex(4)}#{Time.now.to_f}", self.file.extension].reject(&:blank?).join(".").downcase
    token = model.instance_variable_get(var) or model.instance_variable_set(var, new_token)
  end
=end
  def save_content_type_and_size_in_model
    model.doc_type = file.content_type if file.content_type
    model.doc_size = file.size
  end

end
