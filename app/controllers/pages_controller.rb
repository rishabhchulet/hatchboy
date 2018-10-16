class PagesController < ApplicationController

  before_filter :check_session!, :only => [:dashboard, :email]

  def home
    if account_signed_in?
      redirect_to company_path
    else
      render "pages/home", :layout => "custom"
    end
  end

  def email
  end

  def compose
  end

  def billing_information
  end
end
