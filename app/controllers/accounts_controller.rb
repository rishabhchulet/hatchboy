class AccountsController < ApplicationController
  before_filter :check_session!

  def show
    @account = current_account
  end

end
