class ProfilesController < ApplicationController
  before_filter :authenticate_account!

  def show
    @profile = current_account.profile
  end

end
