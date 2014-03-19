# encoding: utf-8
require 'carrierwave/processing/mime_types'

class DocumentUploader < CarrierWave::Uploader::Base
  #include CarrierWave::MimeTypes

  def extension_white_list
    %w(pdf)
  end

  def store_dir
    "uploads/#{Rails.env}/#{model.class.to_s.underscore}/#{model.id.to_s}/"
  end
  
  def root
    Rails.root.to_s + '/public/'
  end

end
