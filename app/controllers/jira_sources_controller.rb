class JiraSourcesController < ApplicationController

  before_filter :authenticate_account!
  
  def new
    new_jira_source
  end
  
  def show
    @jira_source = JiraSource.where(id: params[:id]).first or not_found
  end
  
  def create
    @jira_source = JiraSource.new jira_source_params
    @jira_source.company = account_company
    if @jira_source.save
      session[:jira_source] = {id: @jira_source.id, request_token: @jira_source.request_token.token, request_token_secret: @jira_source.request_token.secret}
      redirect_to @jira_source.request_token.authorize_url(:oauth_callback => "http://shakuro.com#{jira_source_confirm_path(@jira_source, :only_path => true)}")
    else
      render "jira_sources/new"
    end
  end
  
  def edit
    @jira_source = JiraSource.where(id: params[:id]).first or not_found
  end
  
  def update 
    @jira_source = JiraSource.where(id: params[:id]).first or not_found
    if @jira_source.update_attributes(jira_source_params)
      session[:jira_source] = {id: @jira_source.id, request_token: @jira_source.request_token.token, request_token_secret: @jira_source.request_token.secret}
      redirect_to @jira_source.request_token.authorize_url(:oauth_callback => "http://shakuro.com#{jira_source_confirm_path(@jira_source, :only_path => true)}")
    else
      render "companies/edit"
    end
  end
  
  def refresh
    @jira_source = JiraSource.where(id: params[:jira_source_id]).first or not_found
    @jira_source.import!
    redirect_to jira_source_path(@jira_source)
  end
  
  def confirm
    if @jira_source = JiraSource.where(id: params[:jira_source_id]).first
      if (verifier = params[:oauth_verifier])
        #Some code to save oauth_verifier would go here if only JIRA callback routing worked at it should
      else
        redirect_to edit_jira_source_path(@jira_source)
      end
    end
  end
  
  def destroy
    @jira_source = JiraSource.where(id: params[:id]).first or not_found
    @jira_source.destroy
    redirect_to sources_path
  end
  
  def callback
    if !session[:jira_source].blank? and (@jira_source = JiraSource.where(id: session[:jira_source][:id]).first)
      request_token = @jira_source.set_request_token session[:jira_source][:request_token], session[:jira_source][:request_token_secret]
      if (params[:oauth_verifier]) and (params[:oauth_verifier] != 'denied') and
        if (@jira_source.init_access_token!(params[:oauth_verifier]))
          session[:jira_source] = nil
          flash[:notice] = "Jira connection successfully verified"
          redirect_to jira_source_path(@jira_source)
        else
          flash[:warning] = "Jira connection validation failed (#{@jira_source.errors[:verification].first})"
          redirect_to edit_jira_source_path(@jira_source)
        end
      else
        flash[:warning] = "Jira connection validation failed."
        redirect_to edit_jira_source_path(@jira_source)
      end
    else
      redirect_to new_source_path
    end
  end
  
  private
  
  def jira_source_params
    params.require(:jira_source).permit(:name, :consumer_key, :private_key, :url)
  end
  
end
