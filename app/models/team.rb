class Team < ActiveRecord::Base

  belongs_to :company
  belongs_to :created_by, class_name: "User"

  has_many :team_sources, :class_name => "TeamsSources", :dependent => :destroy
  has_many :sources, :through => :team_sources

  has_many :worklogs, :class_name => "WorkLog", :dependent => :destroy

  has_many :team_users, class_name: "TeamsUsers"
  has_many :users, through: :team_users

  has_many :posts, :through => :post_receivers
  has_many :post_receivers, :as => :receiver

  validates :name, :presence => true

end
