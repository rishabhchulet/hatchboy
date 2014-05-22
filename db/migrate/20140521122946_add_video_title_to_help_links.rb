class AddVideoTitleToHelpLinks < ActiveRecord::Migration
  def change
    change_table :help_links do |t|
      t.column :video_title, :string
    end
  end
end
