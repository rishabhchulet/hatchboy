class DashboardController < ApplicationController

  before_filter :check_session!

  def index
    @recent_activity = user_recent_activity
  end

  private

  def user_recent_activity
    PublicActivity::Activity.order("created_at desc").where(company_id: account_company.id)
  end

end

