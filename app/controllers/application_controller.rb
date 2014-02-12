class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include ApplicationHelper

  helper_method :account_company

  private

  def account_company
    current_account.user.company
  end

  def check_session!
    authenticate_account!
    sign_out and redirect_to after_sign_out_path_for(:account) unless current_account.user and current_account.user.company
  end

end

