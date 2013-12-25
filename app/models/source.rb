class Source < ActiveRecord::Base
  
  PROVIDERS = {:jira => "JiraSource"}
  
  attr_accessor :provider
  
  belongs_to :company
  
  validates :provider, inclusion: { in: self::PROVIDERS.keys }, presence: true, :on => :create 
  
  before_create :set_type
  
  private 
  
  def set_type
    self.type = self.class::PROVIDERS[self.provider]
  end 
  
end
