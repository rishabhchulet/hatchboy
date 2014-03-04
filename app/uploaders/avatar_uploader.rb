# encoding: utf-8
require 'carrierwave/processing/mime_types'

class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes
  include CarrierWave::MiniMagick

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  process :resize_to_fit => [200, 200]
  process :set_content_type

  version :thumb do
    process :resize_to_fill => [69,69, 'Center']
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{Rails.env}/#{model.class.to_s.underscore}/#{mounted_as}/"
  end
  
  def root
    Rails.root.to_s + '/public/'
  end

  def default_url
    ActionController::Base.helpers.asset_path("images/" + [version_name, "userpic.jpg"].compact.join('_'))
  end

  def filename
    secure_token if super
  end
  
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    new_token = ["#{SecureRandom.hex(4)}#{Time.now.to_f}", self.file.extension].reject(&:blank?).join(".").downcase
    token = model.instance_variable_get(var) or model.instance_variable_set(var, new_token)
  end

end
