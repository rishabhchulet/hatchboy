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
      session[:trello_source] = {id: @trello_source.id, request_token: @trello_source.request_token}
      redirect_to  @trello_source.get_request_token.authorize_url auth_callback: trello_source_confirm_path(@trello_source, only_path: false), callback_method: "postMessage", name: @trello_source.name
    else
      render "trello_sources/new"
    end
  end

  def update
    @trello_source = TrelloSource.where(id: params[:id]).first or not_found

    if @trello_source.update_attributes(trello_source_params)
      oauth_callback = trello_callback_path(only_path: false)  #trello_source_confirm_path(@trello_source, only_path: true),
      request_token = @trello_source.client.auth_policy.client.get_request_token(oauth_callback: oauth_callback)
      session[:trello_source] = {id: @trello_source.id, request_token: request_token}
      redirect_to("#{request_token.authorize_url}&name=#{@trello_source.name}&expiration=never")
    else
      render "trello_sources/edit"
    end
  end

  def callback
    if !session[:trello_source].blank? and (@trello_source = TrelloSource.where(id: session[:trello_source][:id]).first)
      @trello_source.request_token = session[:trello_source][:request_token]

      if (params[:oauth_verifier]) and (params[:oauth_verifier] != 'denied')
        if (@trello_source.init_access_token!(params[:oauth_verifier]))
          session[:trello_source] = nil
          flash[:notice] = "trello connection successfully verified"
          redirect_to trello_source_path(@trello_source)
        else
          flash[:warning] = "Trello connection validation failed (#{@trello_source.errors[:verification].first})"
          redirect_to edit_trello_source_path(@trello_source)
        end
      else
        flash[:warning] = "Jira connection validation failed."
        redirect_to edit_trello_source_path(@trello_source)
      end
    else
      redirect_to new_source_path
    end
  end

  def confirm
    if @trello_source = TrelloSource.where(id: params[:trello_source_id]).first
      if (verifier = params[:oauth_verifier])
        #Some code to save oauth_verifier would go here if only JIRA callback routing worked at it should
      else
        redirect_to edit_trello_source_path(@trello_source)
      end
    end
  end

  def browse
    @trello_source = TrelloSource.where(id: params[:trello_source_id]).first or not_found
    @trello_source.connect_to_source
    me = @trello_source.client.find(:members, :me)
    me.organizations.first.members.second
    debugger
    123
  end

  def destroy
    @trello_source = TrelloSource.where(id: params[:id]).first or not_found
    @trello_source.destroy
    redirect_to sources_path
  end

  private

  def trello_source_params
    params.require(:trello_source).permit(:name, :consumer_key, :consumer_secret)
  end

end

