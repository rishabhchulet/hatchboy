class ChangeTimeTypeInWorklogs < ActiveRecord::Migration
  def change
    change_column :work_logs, :time, :float
  end
end
