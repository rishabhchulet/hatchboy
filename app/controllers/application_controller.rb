class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include ApplicationHelper
  
  helper_method :account_company
  
  private
  
  def account_company
    current_account.profile.company
  end
  
end
