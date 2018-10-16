class CustomersController < ApplicationController
  
  def index
    @customers = account_company.customers.joins(:account).order("created_at ASC")
  end
  
  def show
    @customer = Customer.where(id: params[:id]).first or not_found
  end
  
end
