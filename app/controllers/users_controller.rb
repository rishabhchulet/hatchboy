class UsersController < ApplicationController

  before_filter :check_session!

  def index
    @users = account_company.users.order("created_at ASC")
  end

  def show
    @user = account_company.users.where(id: params[:id]).first or not_found
  end

  def new
    @user = account_company.users.new
  end

  def create
    @user = account_company.users.create(user_params)
    if @user.valid?
      flash[:notice] = "New user has been successfully added"
      redirect_to after_action_path
    else
      render "users/new"
    end
  end

  def edit
    @user = account_company.users.where(id: params[:id]).first or not_found
  end

  def update
    @user = account_company.users.where(id: params[:id]).first or not_found

    if @user.update_attributes(user_params)
      flash[:notice] = "Information about user has been successfully updated"
      redirect_to after_action_path
    else
      render "users/edit"
    end
  end

  def destroy
    @user = account_company.users.where(id: params[:id]).first or not_found
    @user.destroy
    flash[:notice] = "User has been successfully removed"
    redirect_to after_action_path
  end

  protected

  def user_params
    params.require(:user).permit(:name, :contact_email, :role, :status, :avatar, :avatar_cache, :remove_avatar)
  end

  def after_action_path
    "#{company_path}#users_short_list"
  end
end
