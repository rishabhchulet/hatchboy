class CreateTeamsEmployees < ActiveRecord::Migration
  def change
    create_table :teams_employees do |t|
      t.integer :team_id
      t.integer :employee_id
      t.timestamps
    end
  end
end
