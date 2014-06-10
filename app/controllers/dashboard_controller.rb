class DashboardController < ApplicationController

  before_filter :check_session!

  include ReportsHelper
  include PaymentsHelper
  include WorkLogsHelper
  include PostsHelper

  def index
    if activity_filter = current_account.user.dashboard_activity_filter
      @recent_activity = user_recent_activity DashboardActivityFilter::ACTIVITIES.select{|a| activity_filter[a]}.map{|a| a.to_s.classify}
    end
    
    respond_to do |format|
      format.html { @ratings_report = build_report :ratings }
      format.js
    end
  end

  private

  def user_recent_activity trackable_types = []
    PublicActivity::Activity.order("created_at desc").where(company_id: account_company.id, trackable_type: trackable_types).page(params[:page]).per(10)
  end
end