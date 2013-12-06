class CustomersInvitationsController < Devise::InvitationsController
  before_filter :update_sanitized_params, if: :devise_controller?
  
  def update_sanitized_params
    devise_parameter_sanitizer.for(:invite) {|u| u.permit(:email, profile_attributes: [:name, :type])}
  end
  
  def new
    self.resource = resource_class.new
    self.resource.build_profile(type: "Customer")
    render :new
  end

  def create
    params[:account][:profile_attributes][:type] = "Customer"
    super
  end
  
  protected
  
  def invite_resource
    resource_class.invite!(invite_params, current_inviter) do |invitable|
      invitable.profile.company = current_inviter.profile.company
      invitable.valid?
      invitable.errors[:email] = t("devise.invitations.customer.errors.account_already_confirmed") if invitable.confirmed?
    end
  end

end
