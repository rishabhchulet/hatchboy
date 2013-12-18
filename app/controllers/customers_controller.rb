class CustomersController < ApplicationController
  
  def index
    
  end
  
  def show
    @customer = Customer.where(id: params[:id]).first or not_found
  end
  
end