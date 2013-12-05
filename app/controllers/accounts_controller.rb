class AccountsController < ApplicationController
  before_filter :authenticate_account!

  def show
    @account = current_account
  end

end
