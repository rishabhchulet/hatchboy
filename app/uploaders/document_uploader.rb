# encoding: utf-8
require 'carrierwave/processing/mime_types'

class DocumentUploader < CarrierWave::Uploader::Base
  #include CarrierWave::MimeTypes

  process :set_envelope_id

  def extension_white_list
    %w(pdf)
  end

  def store_dir
    "uploads/#{Rails.env}/#{model.class.to_s.underscore}/#{model.id.to_s}/"
  end
  
  def root
    Rails.root.to_s + '/public/'
  end

  def set_envelope_id
    client = DocusignRest::Client.new
    response = client.create_envelope_from_document(
      email: {
        subject: 'Sign this document PLEASE!',
        body: 'This is the email body.'
      },
      signers: [
        {
          embedded: true,
          name: model.user.name,
          email: model.user.account.email
        }
      ],
      files: [
        {path: file.path.to_s, name: file.filename}
      ],
      status: 'sent'
    )    

    raise CarrierWave::ProcessingError, response["message"] if response["errorCode"]

    model.envelope_id = response["envelopeId"]
    model.status = DocuSign::STATUS_PROCESSING
  end


end
