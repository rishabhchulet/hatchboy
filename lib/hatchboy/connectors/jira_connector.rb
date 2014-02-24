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
        debugger
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

      def import!
        self.connect_to_source
        projects = client.Project.all
        projects.each do |project|
          project_details = client.Project.find(project.id)
          if (team_source = self.source_teams.where(uid: project_details.id).first)
            team = team_source.team
          else
            team = Team.create({company: self.company, name: project_details.name, description: project_details.description})
            team_source = self.source_teams.create(team: team, uid: project_details.id)
          end
          issues = project_details.issues
          issues.each do |issue|
            worklogs = issue.fields["worklog"]["worklogs"]
            worklogs.each do |worklog|
              sources_user = SourcesUser.where(source: self, email: worklog["author"]["emailAddress"]).find_or_create_by({:name => worklog["author"]["name"]})
              team.worklogs.where({
                comment: worklog["comment"], issue: issue.summary, on_date: worklog["started"],
                time: worklog["timeSpentSeconds"], sources_user: sources_user
              }).find_or_create_by(source: self, uid_in_source: worklog["id"])
            end if worklogs and worklogs.any?
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
