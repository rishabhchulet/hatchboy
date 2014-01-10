require "spec_helper"

feature "sources#index" do
  
  background do
    @customer = create :customer
    @session = sign_in! @customer.account
    @jira_source = create :authorized_jira_source, company: @customer.company
    @session.visit sources_path
  end
  
  scenario "it should contain list of sources" do
    data_rows = @session.all("#sources-list .data-row")
    data_rows.count.should eq 1
  end
  
  scenario "it should show source name, url, type info" do
    source_row = @session.all("#sources-list .data-row").first
    source_row.should have_content @jira_source.name
    source_row.should have_content @jira_source.provider
    source_row.should have_content @jira_source.url
  end
  
  scenario "it should have edit link for source" do
    source_row = @session.all("#sources-list .data-row").first
    source_row.hover
    source_row.find(".edit-source-action").click
    @session.current_path.should eq edit_jira_source_path(@jira_source)
  end  

  scenario "it should have view link for source" do
    source_row = @session.all("#sources-list .data-row").first
    source_row.hover
    source_row.find(".view-source-action").click
    @session.current_path.should eq jira_source_path(@jira_source)
  end  

  scenario "should have link to delete source" do
    source_row = @session.all("#sources-list .data-row").first
    source_row.hover
    source_row.find(".list-row-action-delete-one").click
    popup_menu = @session.find(".list-row-action-popover-delete-one")
    popup_menu.should be_visible
    popup_menu.all("div", :text => "Cancel").first.should be_visible
    popup_menu.find(:xpath, ".//input[@value = 'Delete']").should be_visible
  end
  
  scenario "it should have link to add new source" do
    @session.click_link("Add another source")
    @session.current_path.should eq new_source_path
  end
  
  scenario "it should not show sources not related to the company" do
    another_source  = create :authorized_jira_source
    @session.visit sources_path
    data_rows = @session.all("#sources-list .data-row")
    data_rows.count.should eq 1
  end
  
end
