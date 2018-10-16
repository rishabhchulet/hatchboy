class DashboardActivityFiltersController < ApplicationController

  before_filter :check_session!

  def create
    current_account.user.create_dashboard_activity_filter dashboard_activity_filter_params
    redirect_to dashboard_path
  end

  private

    def dashboard_activity_filter_params
      params.require(:dashboard_activity_filter).permit(DashboardActivityFilter::ACTIVITIES)
  end
end
