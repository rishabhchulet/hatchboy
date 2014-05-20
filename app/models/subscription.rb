class Subscription < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user
  
  before_create :default_subscriptions

  SUBSCRIPTION_COLUMNS = [:user_was_added, :user_was_removed, :team_was_added, :team_was_removed,
                          :payment_was_sent, :data_source_was_created, :document_for_signing_was_uploaded,
                          :post_added_to_team, :user_added_to_team, :time_log_added_to_team]

  private

  def default_subscriptions
    SUBSCRIPTION_COLUMNS.each {|column| self[column] = true if self[column].nil?}
    return true
  end

end
