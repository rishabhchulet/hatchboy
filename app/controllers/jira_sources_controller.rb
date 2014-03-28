class JiraSourcesController < ApplicationController

  include SourcesHelper

  before_filter :check_session!

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
      request_token = @jira_source.client.request_client.get_request_token(oauth_callback: jira_source_confirm_path(@jira_source, only_path: false))
      session[:jira_source] = {id: @jira_source.id, request_token: request_token}
      redirect_to request_token.authorize_url
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
      request_token = @jira_source.client.request_client.get_request_token(oauth_callback: jira_source_confirm_path(@jira_source, only_path: false))
      session[:jira_source] = {id: @jira_source.id, request_token: request_token}
      redirect_to request_token.authorize_url
    else
      render "jira_sources/edit"
    end
  end

  def browse
    @jira_source = JiraSource.where(id: params[:jira_source_id]).first or not_found
    @jira_source.read!
  end

  def sync
    @jira_source = JiraSource.where(id: params[:jira_source_id]).first or not_found
    @jira_source.import! jira_sync_params
    redirect_to jira_source_path(@jira_source)
  end

  def confirm
    if @jira_source = JiraSource.where(id: params[:jira_source_id]).first
      if !session[:jira_source].blank? and (session[:jira_source][:id] == @jira_source.id)
        confirm_request_token @jira_source
      else
        redirect_to jira_source_path(@jira_source)
      end
    else
      redirect_to new_source_path
    end
  end

  def callback
    if !session[:jira_source].blank? and (@jira_source = JiraSource.where(id: session[:jira_source][:id]).first)
      confirm_request_token @jira_source
    end
  end

  def destroy
    @jira_source = JiraSource.where(id: params[:id]).first or not_found
    @jira_source.destroy
    redirect_to sources_path
  end

  def generate_public_cert
    public_key = Tempfile.new(['rsakey_pub', '.pem'])
    private_key = Tempfile.new(['rsakey', '.pem'])
    system("openssl req -x509 -subj \"/C=US/ST=New York/L=New York/O=Hatchboy/CN=#{request.host_with_port}\" -nodes -newkey rsa:1024 -sha1 -keyout #{private_key.path} -out #{public_key.path}")
    respond_to do |format|
      responce = { :private_key => File.read(private_key.path).gsub(/\-(.*?)\-/,'').delete("\n"), :public_key => File.read(public_key.path).gsub(/\n/, '<br>') }
      format.json { render :json => responce }
    end
    public_key.delete
    private_key.delete
  end

  private

  def confirm_request_token source
    request_token = session[:jira_source][:request_token]
    source.set_request_token request_token.token, request_token.secret
    if (params[:oauth_verifier]) and (params[:oauth_verifier] != 'denied') and
      if (source.init_access_token!(params[:oauth_verifier]))
        session[:jira_source] = nil
        flash[:notice] = "Jira connection successfully verified"
        redirect_to source
      else
        flash[:warning] = "Jira connection validation failed (#{source.errors[:verification].first})"
        redirect_to [:edit, source]
      end
    else
      flash[:warning] = "Jira connection validation failed."
      redirect_to [:edit, source]
    end
  end

  def jira_source_params
    params.require(:jira_source).permit(:name, :consumer_key, :private_key, :url)
  end

  def jira_sync_params
    params.require(:projects)
  end
end
