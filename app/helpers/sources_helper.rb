module SourcesHelper

  def new_jira_source
    @jira_source = JiraSource.new :company => account_company
  end

  def new_trello_source
    @trello_source = TrelloSource.new :company => account_company
  end

end

