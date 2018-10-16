class StripeRecipientsController < ApplicationController
  before_filter :check_session!
  before_action :set_user
  before_action :set_stripe_configuration

  def show
    @stripe_recipient = @user.stripe_recipient or not_found
  end

  def new
    @stripe_recipient = (@user.stripe_recipient || @user.build_stripe_recipient).dup
  end

  def create
    @stripe = Hatchboy::Payments::Stripe.new @stripe_configuration
    @stripe_recipient = @user.build_stripe_recipient stripe_recipient_params
    if stripe_recipient_params = @stripe.save_recipient(@stripe_recipient) and (@stripe_recipient.assign_attributes(stripe_recipient_params) or @stripe_recipient.save)
      flash[:notice] = "Your stripe configuration has been successfully saved"
      redirect_to account_path
    else
      render "stripe_recipients/new"
    end
  end

  private

    def stripe_recipient_params
      params.require(:stripe_recipient).permit(:full_name, :stripe_token, :recipient_token, :last_4_digits)
    end

    def set_user
      @user = account_company.users.where(id: params[:user_id]).first or not_found
    end

    def set_stripe_configuration
      unless @stripe_configuration = account_company.stripe_configuration
        flash[:warning] = "Stripe is not configured. Please contact the manager."
        redirect_to(company_url)
      end
    end
end
