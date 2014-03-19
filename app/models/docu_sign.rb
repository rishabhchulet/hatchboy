class DocuSign < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :docu_template, :validate => true
  
  validates :user, presence: true

  attr_reader :users

  STATUS_PROCESSING = "processing"
  STATUS_SIGNED = "signed"
  STATUS_CANCELLED = "cancelled"
  
  before_validation :get_envelope

  private
  
  def get_envelope
    client = DocusignRest::Client.new

    response = client.create_envelope_from_template(
      status: 'sent',
      email: {
        subject: "The test email subject envelope",
        body: "Envelope body content here"
      },
      template_id: self.docu_template.template_key,
      signers: [
        {
          embedded: true,
          name: self.user.name,
          email: self.user.account.email,
          role_name: 'Signer'
        }
      ]
    )

    self.status = DocuSign::STATUS_PROCESSING
    self.errors.add(:envelope_key, response["message"] ) unless self.envelope_key = response["envelopeId"]
  end

end
