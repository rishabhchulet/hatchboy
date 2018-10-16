shared_examples "sources list" do
  
  scenario "it should contain list of sources" do
    data_rows = page.all("#sources-list .data-row")
    data_rows.count.should eq 1
  end
  
  scenario "it should show source name, url, type info" do
    source_row = page.all("#sources-list .data-row").first
    source_row.should have_content collection.first.name
    source_row.should have_content collection.first.provider
    source_row.should have_content collection.first.url
  end
  
  scenario "it should have edit link for source" do
    source_row = page.all("#sources-list .data-row").first
    source_row.hover
    source_row.find(".edit-source-action").click
    page.current_path.should eq edit_jira_source_path(collection.first)
  end  

  scenario "it should have view link for source" do
    source_row = page.all("#sources-list .data-row").first
    source_row.hover
    source_row.find(".view-source-action").click
    page.current_path.should eq jira_source_path(collection.first)
  end  

  scenario "should have link to delete source" do
    source_row = page.all("#sources-list .data-row").first
    source_row.hover
    source_row.find(".list-row-action-delete-one").click
    popup_menu = page.find(".list-row-action-popover-delete-one")
    popup_menu.should be_visible
    popup_menu.all("div", :text => "Cancel").first.should be_visible
    popup_menu.find(:xpath, ".//input[@value = 'Delete']").should be_visible
  end
  
  scenario "it should have link to add new source" do
    page.click_link("Add another source")
    page.current_path.should eq new_source_path
  end
  
  scenario "it should not show sources not related to the company" do
    another_source  = create :authorized_jira_source
    page.visit page.current_url
    data_rows = page.all("#sources-list .data-row")
    data_rows.count.should eq 1
  end
end