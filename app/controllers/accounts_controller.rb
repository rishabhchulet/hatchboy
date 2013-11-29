class AccountsController < ApplicationController
  before_filter :authenticate_account!

  def index
    @users = Account.all
  end

  def show
    @user = Account.find(params[:id])
  end

end
