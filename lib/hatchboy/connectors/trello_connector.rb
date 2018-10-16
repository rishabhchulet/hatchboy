module Hatchboy
  module Connectors
    module TrelloConnector

      attr_reader :request_token, :organizations, :boards

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

      def read!
        self.connect_to_source
        me = client.find(:members, :me)
        @organizations = me.organizations.map do |o|
          o_members = o.members.map do |m|
            {id: m.id, name: m.full_name, email: m.email}
          end
          {id: o.id, name: o.display_name, description: o.description, members: o_members}
        end

        @boards = me.boards.map do |b|
          o_members = b.members.map do |m|
            {id: m.id, name: m.full_name, email: m.email}
          end
          {id: b.id, name: b.name, description: b.description, members: o_members}
        end

        [@organizations, @boards].map do |p|
          p.each do |m|
            if (team_source = self.source_teams.where(uid: m[:id]).first)
               m[:team] = team_source.team
            else
               m[:team] = nil
            end
          end
        end

      end

      def import! params
        read!

        [@organizations, @boards].each do |p|
          p.each do |o|
            if o_params = params[o[:id]]
              if o_params['team_id'] == 'new'
                team = Team.create(company: self.company, name: o[:name], description: o[:description])
                team_source = self.source_teams.create(team: team, uid: o[:id])
              elsif team = Team.where(id: o_params["team_id"]).first
                team_source = self.source_teams.find_or_create_by(team: team, uid: o[:id])
              end

              o[:members].each do |u|
                if o_params["users"] and (o_params["users"].include?(u[:id]) or o_params["users"].include?("all"))
                  source_user = self.source_users.where(uid: u[:id]).first
                  debugger
                  unless source_user
#                    email = u[:email].blank? ? "no-email@hatchboy.com" : u[:email]
                    user = User.create(name: u[:name], contact_email: u[:email], company: self.company)
                    source_user = self.source_users.create(uid: u[:id], user: user )
                  end
                  team.users << source_user.user unless team.users.include? source_user.user
                end
              end
            end
          end
        end
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

