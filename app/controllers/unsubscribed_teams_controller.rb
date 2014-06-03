class UnsubscribedTeamsController < ApplicationController
  before_filter :check_session!

  def subscribe
    @unsubscribed_team = current_account.user.unsubscribed_teams.where(id: params[:id]).first or not_found
    @unsubscribed_team.destroy!
    respond_to do |format|
      format.html { redirect_to team_path(@unsubscribed_team.team)}
      format.js
    end
  end

  def unsubscribe
    @team = current_account.user.teams.where(id: params[:team_id]).first or not_found
    current_account.user.unsubscribed_teams.create!(team_id: @team.id)
    respond_to do |format|
      format.html do
        flash[:notice] = "Successfully unsubscribed"
        redirect_to team_path(@team)
      end
      format.js
    end
  end
end
