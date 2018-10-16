# encoding: utf-8
require 'carrierwave/processing/mime_types'

class BaseUploader < CarrierWave::Uploader::Base
  
  def root
    Rails.root.to_s + '/public/'
  end

end
