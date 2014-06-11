class SetDefaultColumnsInDashboardActivityFilters < ActiveRecord::Migration
  def change
    change_table :dashboard_activity_filters do |t|
      t.change :users, :boolean, :default => true
      t.change :post_receivers, :boolean, :default => true
      t.change :payments, :boolean, :default => true
      t.change :docu_signs, :boolean, :default => true
      t.change :sources, :boolean, :default => true
      t.change :teams, :boolean, :default => true
      t.change :work_logs, :boolean, :default => true
    end
  end
end
