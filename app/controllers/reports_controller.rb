class ReportsController < ApplicationController

  before_filter :check_session!

  include ReportsHelper

  def index
    @hours_report = Hatchboy::Reports::Builders::HoursBuilder.new(retrieve_query_params(:hours, Hatchboy::Reports::Builders::HoursBuilder::AVAILABLE_PARAMS))
    @payments_report = Hatchboy::Reports::Builders::PaymentsBuilder.new(retrieve_query_params(:payments, Hatchboy::Reports::Builders::PaymentsBuilder::AVAILABLE_PARAMS))
    @mvp_report = Hatchboy::Reports::Builders::MvpBuilder.new(retrieve_query_params(:mvp, Hatchboy::Reports::Builders::MvpBuilder::AVAILABLE_PARAMS))
    @ratings_report = Hatchboy::Reports::Builders::RatingsBuilder.new({})
    
  rescue Exception => e
    flash.now[:error] = e.message
    render :index
  end
end