class SourcesController < ApplicationController 

  before_filter :authenticate_account!
  
  def index 
    @sources = account_company.sources
  end
  
  def new
    
  end
  
end
