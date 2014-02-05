class JiraSource <  Source

  include Hatchboy::Connector::Jira

  validates :url, :presence => true
  validates :consumer_key, :presence => true
  validates :private_key, :presence => true
  validate :connection

  def provider
    :jira
  end

  private

  def connection
    begin
      client.request_token
    rescue => error
      errors.add(:private_key, %Q{Connection to Jira failed with error: "#{error.message}"})
    end
  end

end

