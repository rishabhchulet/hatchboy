class AddIndexToHelpLinks < ActiveRecord::Migration
  def change
    add_index :help_links, [:controller, :action]
  end
end
