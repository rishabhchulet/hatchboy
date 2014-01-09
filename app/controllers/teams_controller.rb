class TeamsController < ApplicationController
  
  def destroy
    @team = Team.where(id: params[:id]).first or not_found
    @team.destroy
    redirect_to company_path
  end
  
end