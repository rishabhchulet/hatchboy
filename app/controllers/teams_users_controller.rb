class TeamsUsersController < ApplicationController

  before_filter :check_session!

  def new
    @team = account_company.teams.where(id: params[:team_id]).first or not_found
    @team_user = @team.team_users.new
  end

  def create
    @team = account_company.teams.where(id: params[:team_id]).first or not_found
    @team_user = @team.team_users.new team_user_params
    if @team_user.save
      redirect_to team_path(@team)
    else
      render "new"
    end
  end

  def destroy
    @team = account_company.teams.where(id: params[:team_id]).first or not_found
    @user = @team.users.where(id: params[:id]).first or not_found
    @team.users.delete(@user)
    redirect_to team_path(@team)
  end

  private

  def team_user_params
    params.require(:teams_users).permit([:user_id])
  end

end
