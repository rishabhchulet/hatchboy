class DocuTemplate < ActiveRecord::Base
  belongs_to :company
  has_many :docu_signs, :autosave => true

  mount_uploader :document, DocumentUploader
  
  validates :company, :title, :document, :docu_signs, presence: true
  attr_reader :users

  before_validation :get_template

  def users= params
    usersObj = []
    params = params.split(",")

    params.each do |t|
      uGroup = t.split("_")
      case uGroup[0]
        when "team" then usersObj = usersObj.inject( Team.find(uGroup[1]).users.to_a, :<< )
        when "user" then usersObj.push( User.find( uGroup[1] ) )
      end
    end

    usersObj.uniq.each do |user|
      self.docu_signs << DocuSign.new( { :user => user, :docu_template => self } )
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
