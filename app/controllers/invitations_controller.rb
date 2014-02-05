class InvitationsController < Devise::InvitationsController
  before_filter :update_sanitized_params, if: :devise_controller?

  def update_sanitized_params
    devise_parameter_sanitizer.for(:invite) {|u| u.permit(:email, user_attributes: [:name])}
  end

  def new
    self.resource = resource_class.new
    self.resource.build_user
    render :new
  end

  protected

  def invite_resource
    resource_class.invite!(invite_params, current_inviter) do |invitable|
      invitable.user.company = current_inviter.user.company
      invitable.valid?
      invitable.errors[:email] = t("devise.invitations.user.errors.account_already_confirmed") if invitable.confirmed?
    end
  end

end

