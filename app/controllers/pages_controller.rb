class PagesController < ApplicationController
  
  def home
    redirect_to account_dashboard_path if account_signed_in?
  end
  
  def dashboard
    redirect_to root_path unless account_signed_in?
  end
  
end
