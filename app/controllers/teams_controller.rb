class TeamsController < ApplicationController

  before_filter :check_session!

  def new
    @team = Team.new
  end

  def index
    @teams = account_company.teams.order("created_at ASC")
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
    @posts = @team.posts
    @post = Post.new
  end

  def edit
    @team = account_company.teams.where(id: params[:id]).first or not_found
  end

  def update
    @team = account_company.teams.where(id: params[:id]).first or not_found

    if @team.update_attributes(team_params)
      flash[:notice] = "Information about team has been successfully updated"
      redirect_to after_action_path
    else
      render "teams/edit"
    end
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
