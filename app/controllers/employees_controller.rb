class EmployeesController < ApplicationController

  before_filter :authenticate_account!
  
  def index 
    @employees = account_company.employees.order("created_at ASC")
  end
  
  def show
    @employee = account_company.employees.where(id: params[:id]).first or not_found
  end
  
  def new
    @employee = account_company.employees.new
  end
  
  def create
    @employee = account_company.employees.create(employee_params)
    if @employee.valid?
      flash[:notice] = "New employee has been successfully added"
      redirect_to after_action_path
    else
      render "employees/new"
    end
  end
  
  def edit
    @employee = account_company.employees.where(id: params[:id]).first or not_found 
  end

  def update
    @employee = account_company.employees.where(id: params[:id]).first or not_found

    if @employee.update_attributes(employee_params)
      flash[:notice] = "Information about employee has been successfully updated"
      redirect_to after_action_path
    else
      render "employees/edit"
    end
  end
  
  def destroy
    @employee = account_company.employees.where(id: params[:id]).first or not_found
    @employee.destroy
    flash[:notice] = "Employee has been successfully removed"
    redirect_to after_action_path
  end
  
  protected
  
  def employee_params
    params.require(:employee).permit(:name, :contact_email, :role, :status)
  end
  
  def after_action_path
    "#{company_path}#employees_short_list"
  end
end
