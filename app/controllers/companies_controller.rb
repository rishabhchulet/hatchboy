class CompaniesController < ApplicationController

  before_filter :authenticate_account!
  
  def show
    @company = current_account.profile.company
  end

  def edit
    @company = current_account.profile.company
  end
  
  def update
    @company = current_account.profile.company

    if @company.update_attributes(company_params)
      flash[:notice] = "Information about your company has been successfully updated"
      redirect_to company_path
    else
      render "companies/edit"
    end
  end

  private 
  
  def company_params 
    params.require(:company).permit(:name, :description)
  end
end
