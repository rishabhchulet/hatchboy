class TeamsEmployeesController < ApplicationController

  before_filter :authenticate_account!

  def new
    @team = account_company.teams.where(id: params[:team_id]).first or not_found
    @team_employee = @team.team_employees.new
  end
  
  def create
    @team = account_company.teams.where(id: params[:team_id]).first or not_found
    @team_employee = @team.team_employees.new team_employees_params
    if @team_employee.save
      redirect_to team_path(@team)
    else
      render "new"
    end
  end
  
  def destroy
    @team = account_company.teams.where(id: params[:team_id]).first or not_found
    @employee = @team.employees.where(id: params[:id]).first or not_found
    @team.employees.delete(@employee)
    redirect_to team_path(@team)
  end
  
  private
   
  def team_employees_params
    params.require(:teams_employees).permit([:employee_id])
  end
  
end
