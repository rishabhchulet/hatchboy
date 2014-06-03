class Source < ActiveRecord::Base
  include PublicActivity::Model
  tracked only: :create,
          owner: ->(controller, model) { controller && controller.current_user },
          company_id: ->(controller, source) { source.company.id },
          comments: ->(controller, source) { {name: source.name}.to_json }

  PROVIDERS = {:jira => "JiraSource"}

  attr_accessor :provider

  belongs_to :company

  has_many :source_teams, :class_name => "TeamsSources"
  has_many :teams, :through => :source_teams, :source => :team

  has_many :source_users, :class_name => "SourcesUser"
  has_many :users, :through => :source_users, :source => :user

  has_many :worklogs, :class_name => "WorkLog"

  has_many :source_users, :class_name => "SourcesUser"

  validates :provider, inclusion: { in: self::PROVIDERS.keys }, presence: true, :on => :create, :if => "self.type.blank?"

  validates :name, presence: true

  validates :company, presence: true

  before_create :set_type, :if => "self.type.blank?"

  private

  def set_type
    self.type = self.class::PROVIDERS[self.provider]
  end

end

