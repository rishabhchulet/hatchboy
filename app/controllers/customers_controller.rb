class CustomersController < ApplicationController
  
  
  def show
    @customer = Customer.where(id: params[:id]).first or not_found
  end
  
end