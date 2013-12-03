class AccountsController < ApplicationController
  before_filter :authenticate_account!

  def show
    @user = Account.find(current_account)
  end

end
