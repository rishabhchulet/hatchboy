class RegistrationsController < Devise::RegistrationsController
  before_filter :update_sanitized_params, if: :devise_controller?

  def update_sanitized_params
    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:name, :email, :password, :password_confirmation, profile_attributes: [:name, :type, :company_attributes => [:name] ])}
    devise_parameter_sanitizer.for(:account_update) {|u| u.permit(:name, :email, :password, :password_confirmation, :current_password)}
  end

  def new
    build_resource({})
    self.resource.profile = Customer.new(company: Company.new)
    
    respond_with self.resource
  end

  def create
    params[:account][:profile_attributes][:type] = "Customer"
    super
  end

  protected

  def after_update_path_for(resource)
    account_path
  end
  
end
