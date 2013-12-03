class CompaniesController < ApplicationController

  before_filter :authenticate_account!
  
  def show
    @company = current_account.profile.company
  end

  def edit
  end
  
  def update
    
  end

end