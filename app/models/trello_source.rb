class TrelloSource <  Source

  include Hatchboy::Connectors::TrelloConnector

  validates :consumer_key, :presence => true
  validates :consumer_secret, :presence => true
  validate :connection

  def provider
    :trello
  end

  private

  def connection
    begin
      get_request_token
    rescue => error
      errors.add(:consumer_secret, %Q{Connection to Trello failed with error: "#{error.message}"})
    end
  end

end

