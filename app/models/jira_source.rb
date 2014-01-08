require File.expand_path("lib/connectors/jira_connector")

class JiraSource <  Source
  
  include Hatchboy::Connector::Jira

  validate :connection
  
  def provider
    :jira
  end
  
  private
  
  def connection
    begin
      client.request_token
    rescue => error
      errors.add(:url, %Q{Connection to Jira failed with error: "#{error.message}"})
    end
  end

end
