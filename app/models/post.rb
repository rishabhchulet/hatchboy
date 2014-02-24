class Post < ActiveRecord::Base
  belongs_to  :user
  has_many    :post_receivers, dependent: :destroy
  has_many    :teams, :through => :post_receivers, :source => :receiver, :source_type => "Team"
  has_many    :documents, as: :owner, :dependent => :destroy

  validates   :subject, presence: true
  validates   :message, presence: true
  
  def documents=(attrs)
   attrs.each do |attr| 
      self.documents.build( :doc_file => attr)
    end
  end

end
