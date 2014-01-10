module JiraSourcesHelper

  def new_jira_source
    @jira_source = JiraSource.new :company => account_company
  end

end
