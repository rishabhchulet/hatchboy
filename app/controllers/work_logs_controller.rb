class WorkLogsController < ApplicationController

  before_filter :check_session!

  def new
    @team = account_company.teams.where(id: params[:team_id]).first or not_found
    @work_log = @team.worklogs.new
  end

  def create
    @team = account_company.teams.where(id: params[:team_id]).first or not_found
    @work_log = @team.worklogs.create work_log_params
    if @work_log.valid?
      flash[:notice] = "New work time logged"
      redirect_to team_path(@team)
    else
      render "work_logs/new"
    end
  end

  def edit
    @team = account_company.teams.where(id: params[:team_id]).first or not_found
    @work_log = @team.worklogs.where(id: params[:id]).first or not_found
  end

  def update
    @team = account_company.teams.where(id: params[:team_id]).first or not_found
    @work_log = @team.worklogs.where(id: params[:id]).first or not_found
    if @work_log.update_attributes(work_log_params)
      flash[:notice] = "Information about work time has been successfully updated"
      redirect_to team_path(@team)
    else
      render "work_logs/edit"
    end
  end

  def destroy
    @team = account_company.teams.where(id: params[:team_id]).first or not_found
    @work_log = @team.worklogs.where(id: params[:id]).first or not_found
    @work_log.destroy
    redirect_to team_path(@team)
  end

  private

  def work_log_params
    params.require(:work_log).permit(:user_id, :issue, :on_date, :time, :comment)
  end

end
