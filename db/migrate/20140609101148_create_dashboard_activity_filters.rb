class CreateDashboardActivityFilters < ActiveRecord::Migration
  def change
    create_table :dashboard_activity_filters do |t|
      t.integer :user_id     
      t.boolean :users
      t.boolean :post_receivers
      t.boolean :payments
      t.boolean :docu_signs
      t.boolean :sources
      t.boolean :teams
      t.boolean :work_logs
    end
    
    add_index :dashboard_activity_filters, :user_id
  end
end
