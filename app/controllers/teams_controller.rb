class TeamsController < ApplicationController

  before_filter :authenticate_account!
  
  def new 
    @team = Team.new
  end

  def create
    @team = account_company.teams.create(team_params)
    if @team.valid?
      flash[:notice] = "New team has been successfully added"
      redirect_to after_action_path
    else
      render "teams/new"
    end
  end
  
  def show
    @team = account_company.teams.where(id: params[:id]).first or not_found
  end

  def destroy
    @team = Team.where(id: params[:id]).first or not_found
    @team.destroy
    redirect_to company_path
  end
  
  private
  
  def team_params
    params.require(:team).permit(:name, :description)
  end

  def after_action_path
    "#{company_path}#teams-short-list"
  end
  
end