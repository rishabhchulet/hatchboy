shared_examples "users list" do

  scenario "it should contain information abount users" do
    data_rows = page.all("#users-short-list .data-row")
    data_rows.count.should eq collection.count
    data_rows.first.should have_content collection.first.name
    data_rows.first.should have_content collection.first.contact_email
    data_rows.first.should have_content collection.first.status
    data_rows.first.should have_content collection.first.role
  end

  scenario "should have link to view users data" do
    data_row = page.all("#users-short-list .data-row")[1]
    data_row.hover
    data_row.find(".view-profile-action").click
    page.current_path.should eq user_path(collection.second)
  end

  scenario "should have link to edit users data" do
    data_row = page.all("#users-short-list .data-row")[1]
    data_row.hover
    data_row.find(".edit-profile-action").click
    page.current_path.should eq edit_user_path(collection.second)
  end

end
