class DashboardController < ApplicationController

  before_filter :check_session!

  include ReportsHelper
  include PaymentsHelper
  include WorkLogsHelper
  include PostsHelper

  def index
    current_account.user.create_dashboard_activity_filter unless current_account.user.dashboard_activity_filter
    @recent_activity = user_recent_activity DashboardActivityFilter::ACTIVITIES.select{|a| current_account.user.dashboard_activity_filter[a]}.map{|a| a.to_s.classify}
    
    respond_to do |format|
      format.html do
        @ratings_report = Hatchboy::Reports::Builders::RatingsBuilder.new({date: 'period', period_from: 1.month.ago.at_beginning_of_month, period_to: Time.now})
        @ratings_report.set_company(account_company).build_report_data({chart: true})
      end
      format.js
    end
  end

  private

  def user_recent_activity trackable_types = []
    PublicActivity::Activity.order("created_at desc").where(company_id: account_company.id, trackable_type: trackable_types).page(params[:page]).per(10)
  end
end