class TrelloSourcesController < ApplicationController

  include SourcesHelper

  before_filter :check_session!

  def new
    new_trello_source
  end

  def show
    @trello_source = TrelloSource.where(id: params[:id]).first or not_found
  end

  def edit
    @trello_source = TrelloSource.where(id: params[:id]).first or not_found
  end

  def create
    @trello_source = TrelloSource.new trello_source_params
    @trello_source.company = account_company
    if @trello_source.save
      oauth_callback = trello_source_confirm_path(@trello_source, only_path: true) #trello_callback_path(only_path: false)
      request_token = @trello_source.client.auth_policy.client.get_request_token(oauth_callback: oauth_callback)
      session[:trello_source] = {id: @trello_source.id, request_token: request_token}
      redirect_to request_token.authorize_url(name: @trello_source.name, expiration: "never", scope: "read,write,account")
    else
      render "trello_sources/new"
    end
  end

  def update
    @trello_source = TrelloSource.where(id: params[:id]).first or not_found

    if @trello_source.update_attributes(trello_source_params)
      oauth_callback = trello_source_confirm_path(@trello_source, only_path: false)
      request_token = @trello_source.client.auth_policy.client.get_request_token(oauth_callback: oauth_callback, scope: "read")
      debugger
      session[:trello_source] = {id: @trello_source.id, request_token: request_token}
      redirect_to request_token.authorize_url(name: @trello_source.name, expiration: "never", scope: "read,write,account")
    else
      render "trello_sources/edit"
    end
  end

  def browse
    @trello_source = TrelloSource.where(id: params[:trello_source_id]).first or not_found
    @trello_source.read!
  end

  def sync
    @trello_source = TrelloSource.where(id: params[:trello_source_id]).first or not_found
    @trello_source.import! trello_sync_params
    redirect_to trello_source_path(@trello_source)
  end

  def confirm
    if @trello_source = TrelloSource.where(id: params[:trello_source_id]).first
      if !session[:trello_source].blank? and (session[:trello_source][:id] == @trello_source.id)
        confirm_request_token @trello_source
      else
        redirect_to @trello_source
      end
    else
      redirect_to new_source_path
    end
  end

  def callback
    if !session[:trello_source].blank? and (@trello_source = TrelloSource.where(id: session[:trello_source][:id]).first)
      confirm_request_token @trello_source
    else
      redirect_to new_source_path
    end
  end

  def destroy
    @trello_source = TrelloSource.where(id: params[:id]).first or not_found
    @trello_source.destroy
    redirect_to sources_path
  end

  private

  def confirm_request_token source
    source.request_token = session[:trello_source][:request_token]

    if (params[:oauth_verifier]) and (params[:oauth_verifier] != 'denied')
      if (source.init_access_token!(params[:oauth_verifier]))
        session[:trello_source] = nil
        flash[:notice] = "trello connection successfully verified"
        redirect_to source
      else
        flash[:warning] = "Trello connection validation failed (#{source.errors[:verification].first})"
        redirect_to [:edit, source]
      end
    else
      flash[:warning] = "Trello connection validation failed."
      redirect_to [:edit, source]
    end
  end

  def trello_source_params
    params.require(:trello_source).permit(:name, :consumer_key, :consumer_secret)
  end

  def trello_sync_params
    params.require(:projects)
  end

end

