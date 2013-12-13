class EmployeesController < ApplicationController
  
  
  def new
    @employee = Employee.new
  end
  
  def create
    @employee = Employee.create(employee_params)
    
    if @employee.valid?
      respond_with({}, :location => company_path)
    else
      render "employees/new"
    end
    
  end
  
  def employee_params 
    params.permit(:name, :contact_email, :role, :status)
  end
  
end