class ReportsController < ApplicationController

  before_filter :check_session!

  include ReportsHelper

  def index
    @hours_report = build_report :hours
    @payments_report = build_report :payments
    @mvp_report = build_report :mvp
    @ratings_report = build_report :ratings
  end
end