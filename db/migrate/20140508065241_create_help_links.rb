class CreateHelpLinks < ActiveRecord::Migration
  def up
    create_table :help_links do |t|
      t.string  :controller
      t.string  :action
      t.string  :link
      t.string  :video_link

      t.timestamps
    end
  end

  def down
    drop_table :help_links
  end
end
