module Hatchboy
  module Connector
    module Jira
      
      delegate :request_token, :set_request_token, :set_access_token, :init_access_token, :to => :jira_connection
      
      def connect_to_source
        jira_connection.set_access_token self.access_token, self.access_token_secret if self.access_token and self.access_token_secret
      end
      
      def init_access_token! oauth_verifier
        jira_connection.init_access_token(oauth_verifier: oauth_verifier)
        self.update_attributes({
          access_token: jira_connection.access_token.token,
          access_token_secret: jira_connection.access_token.secret
        })
      end
      
      def jira_connection
        unless @jira_connection
          key_file = Tempfile.new "private_key_"
          key_file.write self.private_key
          key_file.close
  
          jira_options = {
            site:             self.url,
            consumer_key:     self.consumer_key,
            context_path:     "",
            private_key_file: key_file.path
          }
          @jira_connection = ::JIRA::Client.new(jira_options)
        end
        @jira_connection
      end
      
      def import_all
        self.connect_to_source
        projects = jira_connection.Project.all
        projects.each do |project|
          project_details = jira_connection.Project.find(project.id)
          if (team_source = self.source_teams.where(uid: project_details.id).first)
            team = team_source.team
          else
            team = Team.create({company: self.company, name: project_details.name, description: project_details.description})
            team_source = self.source_teams.create(team: team, uid: project_details.id)
          end
          issues = project_details.issues
          issues.each do |issue|
            issue_details = jira_connection.Issue.find(issue.id)
            worklogs = issue_details.fields["worklog"]["worklogs"]
            worklogs.each do |worklog|
              sources_user = SourcesUser.where(source: self, email: worklog["author"]["emailAddress"]).find_or_create_by({:name => worklog["author"]["name"]})
              team.worklogs.where({
                comment: worklog["comment"], issue: issue_details.summary, on_date: worklog["started"], 
                time: worklog["timeSpentSeconds"], sources_user: sources_user
              }).find_or_create_by(source: self, uid_in_source: worklog["id"])
            end if worklogs and worklogs.any?
          end
        end
      end
      
    end
  end
end
