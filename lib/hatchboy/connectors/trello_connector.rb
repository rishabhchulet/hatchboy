module Hatchboy
  module Connectors
    module TrelloConnector

      attr_reader :request_token

      def connect_to_source
        @client = Trello::Client.new({
          consumer_key: self.consumer_key,
          consumer_secret: self.consumer_secret,
          oauth_token: self.access_token,
          oauth_token_secret: self.access_token_secret,
        })
      end

      def client
        params = {
          consumer_key: self.consumer_key,
          consumer_secret: self.consumer_secret,
        }
        @client ||= Trello::Client.new(params)
      end

      def get_request_token
        @request_token ||= client.auth_policy.client.get_request_token
      end

      def request_token= token
        @request_token = token
      end

      def init_access_token! oauth_verifier
        access_token = @request_token.get_access_token(oauth_verifier: oauth_verifier)
        self.update_attributes({
          access_token: access_token.token,
          access_token_secret: access_token.secret
        })
      rescue => error
        self.errors.add(:verification, error.message)
        false
      end

    end
  end
end

module Trello
  module Authorization
    class OAuthPolicy

      def client *params
        consumer *params
      end

    end
  end
end

