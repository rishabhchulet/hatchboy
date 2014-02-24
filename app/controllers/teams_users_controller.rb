class TeamsUsersController < ApplicationController

  before_filter :check_session!

  def new_user
    @team = account_company.teams.where(id: params[:team_id]).first or not_found
    @team_user = @team.team_users.new
    render "new_user"
  end

  def new_team
    @user = account_company.users.where(id: params[:user_id]).first or not_found
    @team_user = @user.user_teams.new
    render "new_team"
  end

  def create_user
    @team = account_company.teams.where(id: params[:team_id]).first or not_found
    @team_user = @team.team_users.new team_user_params
    if @team_user.save
      redirect_to team_path(@team)
    else
      render "new_user"
    end
  end

  def create_team
    @user = account_company.users.where(id: params[:user_id]).first or not_found
    @team_user = @user.user_teams.new user_team_params
    if @team_user.save
      redirect_to user_path(@user)
    else
      render "new_team"
    end
  end

  def destroy
    @team = account_company.teams.where(id: params[:team_id]).first or not_found
    @user = @team.users.where(id: params[:id]).first or not_found
    @team.users.delete(@user)
    redirect_to request.referer.blank? ? team_path(@team) : request.referer
  end

  private

  def team_user_params
    params.require(:teams_users).permit([:user_id])
  end

  def user_team_params
    params.require(:teams_users).permit([:team_id])
  end

end

