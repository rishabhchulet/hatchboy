class PagesController < ApplicationController
  
  before_filter :authenticate_account!, :only => [:dashboard, :email]
  
  def home
    if account_signed_in?
      redirect_to company_path
    else 
      render "pages/home", :layout => "custom"
    end
  end
  
  def dashboard
  end
  
  def email
  end
  
  def compose
  end
end
