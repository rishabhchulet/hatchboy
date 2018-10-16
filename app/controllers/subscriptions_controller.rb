class SubscriptionsController < ApplicationController
  before_filter :check_session!
  before_action :find_or_create_subscription, only: [:edit, :update, :unsubscribe]

  def edit; end

  def update
    @subscription.update_attributes! subscription_params
    respond_to do |format|
      flash[:notice] = "Subscriptions have been successfully saved"
      format.html { redirect_to account_path }
    end
  end

  def unsubscribe
    if Subscription::SUBSCRIPTION_COLUMNS.include? unsubscribe_params[:from].to_sym
      @subscription.update! unsubscribe_params[:from] => false
      flash[:notice] = "Successfully unsubscribed"
    end

    redirect_to account_path
  end

  private

    def subscription_params
      params.require(:subscription).permit(Subscription::SUBSCRIPTION_COLUMNS)
    end

    def unsubscribe_params
      params.permit :from
    end

    def find_or_create_subscription
      @subscription = current_account.user.subscription ? current_account.user.subscription : current_account.user.create_subscription
    end
end
