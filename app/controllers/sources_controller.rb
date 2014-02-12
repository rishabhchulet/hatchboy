class SourcesController < ApplicationController

  before_filter :check_session!

  def index
    @sources = account_company.sources
  end

  def new

  end

end
