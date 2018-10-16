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
    respond_to do |format|
      if @team_user.save
        format.html { redirect_to user_path(@user) }
        format.json { render json: { team: @team_user.team.to_json, users_count: @team_user.team.users.count } }
      else
        format.html { render "new_team" }
        format.json { render json: { errors: @team_user.errors.full_messages } }
      end
    end
  end

  def destroy
    @team = account_company.teams.where(id: params[:team_id]).first or not_found
    team_user = @team.team_users.where(user_id: params[:id]).first or not_found
    @user = team_user.user
    team_user.destroy
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