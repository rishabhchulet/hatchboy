class ReportsController < ApplicationController

  before_filter :check_session!

  include ReportsHelper

  def index
    @hours_report = Hatchboy::Reports::Builders::HoursBuilder.new(account_company, retrieve_query_params(:hours, Hatchboy::Reports::Builders::HoursBuilder::AVAILABLE_PARAMS))
    @payments_report = Hatchboy::Reports::Builders::PaymentsBuilder.new(account_company, retrieve_query_params(:payments, Hatchboy::Reports::Builders::PaymentsBuilder::AVAILABLE_PARAMS))
    @mvp_report = Hatchboy::Reports::Builders::MvpBuilder.new(account_company, retrieve_query_params(:mvp, Hatchboy::Reports::Builders::MvpBuilder::AVAILABLE_PARAMS))
    @ratings_report = Hatchboy::Reports::Builders::RatingsBuilder.new(account_company, {})
  end
end