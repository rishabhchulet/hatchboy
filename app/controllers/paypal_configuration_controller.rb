class PaymentsController < ApplicationController

  before_filter :authenticate_account!
  
  def new
    @params = account_company.paypal_configuration.new
  end

  def create
    if Hatchboy::Payments::Paypal.new(config_params).valid?
      account_company.create_paypal_configuration config_params
      flash[:notice] = "You have succesfully set a paypal configuration"

      redirect_to :payments_path
    else
      flash[:error] = "Please enter valid paypal api login, password and signature"
      @params = account_company.build_paypal_configuration config_params
      @params.valid?

      render :edit
    end
  end

  def edit
    @params = account_company.paypal_configuration
  end

  def update
    create
  end

 
  private
  
  def config_params
    params.require(:paypal_configuration).permit(:login, :password, :credentials)
  end

end
