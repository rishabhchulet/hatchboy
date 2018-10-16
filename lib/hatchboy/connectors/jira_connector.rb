module Hatchboy
  module Connectors
    module JiraConnector

      delegate :request_token, :set_request_token, :set_access_token, :init_access_token, :to => :client

      attr_reader :projects, :users

      def connect_to_source
        client.set_access_token self.access_token, self.access_token_secret if self.access_token and self.access_token_secret
      end

      def init_access_token! oauth_verifier
        client.init_access_token(oauth_verifier: oauth_verifier)
        self.update_attributes({
          access_token: client.access_token.token,
          access_token_secret: client.access_token.secret
        })
      rescue => error
        self.errors.add(:verification, error.message)
        false
      end

      def client
        unless @client
          key_file = Tempfile.new "private_key_"
          key_file.write self.private_key
          key_file.close

          jira_options = {
            site:             self.url,
            consumer_key:     self.consumer_key,
            context_path:     "",
            private_key_file: key_file.path
          }
          @client = ::JIRA::Client.new(jira_options)
        end
        @client
      end

      def read!
        self.connect_to_source
        @projects = []
        client.Project.all.each do |project|
          project_details = client.Project.find(project.id)
          project_details.users
          project_details.issues

          if (team_source = self.source_teams.where(uid: project_details.id).first)
            project_details.attrs["team"] = team = team_source.team
          else
            project_details.attrs["team"] = nil
          end
          @projects << project_details
        end
      end

      
      def import! params
        read!

        @projects.each do |project|

          if project_params = params[project.name]
            if project_params['team_id'] == 'new'
              team = Team.create({company: self.company, name: project.name, description: project.description})
              team_source = self.source_teams.create(team: team, uid: project.id)
            elsif team = Team.where(id: project_params["team_id"]).first
              team_source = self.source_teams.find_or_create_by(team: team, uid: project.id)
            end

            project.users.each do |jira_user|
              if project_params["users"] and (project_params["users"].include?(jira_user.name) or project_params["users"].include?("all"))
                source_user = self.source_users.where(uid: jira_user.name).first
                unless source_user
                  user = User.create_with(name: jira_user.displayName).find_or_create_by(contact_email: jira_user.emailAddress, company: self.company)
                  source_user = self.source_users.create(uid: jira_user.name, user: user )
                end
                team.users << source_user.user unless team.users.include? source_user.user
              end
            end

            project.issues.each do |issue|
              issue.worklogs.each do |worklog|
                if source_user = self.source_users.where(uid: worklog.author.name).first
                  log = team.worklogs.create_with({
                    comment: worklog.comment, issue: issue.summary, on_date: worklog.started,
                    time: (worklog.timeSpentSeconds.to_i / 3600.0), user: source_user.user
                  }).find_or_create_by(source: self, uid_in_source: worklog.id)
                end

              end if issue.worklogs and issue.worklogs.any?
            end

          end
        end
      end
      
    end
  end
end

class JIRA::Resource::Project
  def issues
    unless attrs["issues"]
      response = client.get(client.options[:rest_base_path] + "/search?jql=project%3D'#{key}'&fields=worklog,summary&expand")
      json = self.class.parse_json(response.body)
      attrs["issues"] = json['issues'].map do |issue|
        client.Issue.build(issue)
      end
    end
    attrs["issues"]
  end

  def users
    unless attrs["users"]
      response = client.get(client.options[:rest_base_path] + "/user/assignable/search?project=#{key}")
      json = self.class.parse_json(response.body)
      attrs["users"] = json.map{|u| JIRA::Resource::User.build(self, u)}
    end
    attrs["users"]
  end
end
