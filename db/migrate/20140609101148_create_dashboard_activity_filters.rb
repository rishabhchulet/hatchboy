class CreateDashboardActivityFilters < ActiveRecord::Migration
  def change
    create_table :dashboard_activity_filters do |t|
      t.integer :user_id     
      t.boolean :users, :default => true
      t.boolean :post_receivers, :default => true
      t.boolean :payments, :default => true
      t.boolean :docu_signs, :default => true
      t.boolean :sources, :default => true
      t.boolean :teams, :default => true
      t.boolean :work_logs, :default => true
    end
    
    add_index :dashboard_activity_filters, :user_id
  end
end
