# encoding: utf-8
class DocumentUploader < BaseUploader
  #include CarrierWave::MimeTypes

  def extension_white_list
    %w(pdf)
  end

  def store_dir
    "uploads/#{Rails.env}/#{model.class.to_s.underscore}/#{model.id.to_s}/"
  end
  
end
