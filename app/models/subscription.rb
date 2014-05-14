class Subscription < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user
  
  before_create :default_subscriptions

  private

  def default_subscriptions
    self.user_was_added = true if self.user_was_added.nil?
    self.user_was_removed = true if self.user_was_removed.nil?
    self.team_was_added = true if self.team_was_added.nil?
    self.team_was_removed = true if self.team_was_removed.nil?
    self.payment_was_sent = true if self.payment_was_sent.nil?
    self.data_source_was_created = true if self.data_source_was_created.nil?
    self.document_for_signing_was_uploaded = true if self.document_for_signing_was_uploaded.nil?
    self.data_source_added_to_team = true if self.data_source_added_to_team.nil?
    self.post_added_to_team = true if self.post_added_to_team.nil?
    self.user_added_to_team = true if self.user_added_to_team.nil?
    self.time_log_added_to_team = true if self.time_log_added_to_team.nil?
    return true
  end

end
