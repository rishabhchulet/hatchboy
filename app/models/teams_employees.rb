class TeamsEmployees < ActiveRecord::Base
  
  belongs_to :team, foreign_key: "team_id"
  belongs_to :employee, foreign_key: "employee_id"
  validates_presence_of :team
  validates_presence_of :employee
  validates_uniqueness_of :employee_id, scope: [:team_id], message: "has already been added"
  validate :companies_equality
  
  private
  
  def companies_equality
    errors.add :employee_id, "Company should match team's company" unless team.company == employee.company
  end
end
