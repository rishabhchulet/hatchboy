class DocuTemplate < ActiveRecord::Base
  include PublicActivity::Model
  tracked only: :create,
          owner: ->(controller, model) { controller && controller.current_user },
          company_id: ->(controller, docu_template) { docu_template.company_id },
          comments: ->(controller, docu_template) { {title: docu_template.title}.to_json }

  belongs_to :company
  belongs_to :user

  has_many :docu_signs, :autosave => true
  has_many :docu_sign_users, through: :docu_signs, source: :user

  mount_uploader :document, DocumentUploader
  
  validates :company, :title, :document, :recipients, presence: true

  attr_accessor :self_sign
  attr_accessor :envelope_key
  attr_accessor :recipients

  before_validation :get_template
  before_validation :set_docusigns

  def set_docusigns
    usersObj = []
    params = self.recipients.split(",")

    params.each do |t|
      uGroup = t.split("_")

      case uGroup[0]
        when "team" then usersObj = usersObj.inject( Team.find(uGroup[1]).users.to_a, :<< )
        when "user" then usersObj.push( User.find( uGroup[1] ) )
      end
    end

    usersObj.delete_if { |user| user.id == self.user.id } unless self.self_sign.to_i == 0

    usersObj.uniq.each do |user|
      self.docu_signs << DocuSign.new( { :user => user, :docu_template => self } ) if user.account
    end
  end

  private
  
  def get_template
    return if self.document.blank?
    client = DocusignRest::Client.new

    # creating a template
    response = client.create_template(
      name: "Template Name empty signer",
      description: 'Template Description',
      signers: [],
      files: [
        { path: self.document.path.to_s, name: self.document.filename }
      ]
    )

    self.errors.add(:users, response["message"] ) unless self.template_key = response["templateId"]
  end
end
