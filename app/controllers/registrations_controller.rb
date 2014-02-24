class RegistrationsController < Devise::RegistrationsController
  before_filter :update_sanitized_params, if: :devise_controller?

  def update_sanitized_params
    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:name, :email, :password, :password_confirmation, user_attributes: [
      :name, :type, :company_attributes => [:name]
    ])}
    devise_parameter_sanitizer.for(:account_update) {|u| u.permit(:name, :email, :password, :password_confirmation, :current_password,
      user_attributes: [ :name, :avatar, :avatar_cache, :remove_avatar ]
    )}
  end

  def new
    build_resource({})
    respond_with self.resource
  end

  def create
    super
  end

  protected

  def after_update_path_for(resource)
    account_path
  end

  def update_resource(resource, params)
    resource.update_with_password(params)
  end

  def build_resource params
    super
    self.resource.user = User.new(company: Company.new) unless self.resource.user
    self.resource.user.contact_email = self.resource.email
  end

end

