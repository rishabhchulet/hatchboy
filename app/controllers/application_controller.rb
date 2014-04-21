class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include PublicActivity::StoreController

  include ApplicationHelper

  helper_method :account_company

  def current_user
    current_account.user if current_account
  end

  hide_action :current_user

  private

  def account_company
    current_account.user.company
  end

  def check_session!
    authenticate_account!
    sign_out and redirect_to after_sign_out_path_for(:account) unless current_account.user and current_account.user.company
  end

  def store_docs_to_sign
    session[:docs_to_sign] = DocuSign.where(:user => current_account.user).select{|doc| doc.status == DocuSign::STATUS_PROCESSING }.count if current_account
  end

  def after_sign_in_path_for(resource)
    store_docs_to_sign
    super
  end
end

