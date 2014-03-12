class PaypalConfigurationsController < ApplicationController

  before_filter :authenticate_account!
  
  def create
    if Hatchboy::Payments::Paypal.new(config_params).valid?
      account_company.create_paypal_configuration config_params
      flash[:notice] = "You have succesfully set a paypal configuration"

      redirect_to :payments
    else
      flash[:error] = "Please enter valid paypal api login, password and signature"
      @config = account_company.build_paypal_configuration config_params
      @config.valid?

      render :new
    end
  end

  def new
    @config = (account_company.paypal_configuration.dup || account_company.build_paypal_configuration)
  end

  private

  def config_params
    params.require(:paypal_configuration).permit(:login, :password, :signature)
  end

end
