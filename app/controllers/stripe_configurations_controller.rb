class StripeConfigurationsController < ApplicationController
  before_filter :authenticate_account!
  
  def create
    if Hatchboy::Payments::Stripe.new(config_params).valid?
      account_company.create_stripe_configuration config_params
      flash[:notice] = "You have succesfully set a stripe configuration"

      redirect_to :payments
    else
      flash[:error] = "Please enter valid stripe api secret key and public key"
      @config = account_company.build_stripe_configuration config_params
      @config.valid?

      render :new
    end
  end

  def new
    @config = (account_company.stripe_configuration || account_company.build_stripe_configuration).dup
  end

  private

  def config_params
    params.require(:stripe_configuration).permit(:secret_key, :public_key)
  end

end
