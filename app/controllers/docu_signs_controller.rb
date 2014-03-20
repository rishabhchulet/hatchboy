class DocuSignsController < ApplicationController

  before_action :set_docu_sign, only: [:server_response, :show, :edit, :update, :destroy]
  before_filter :authenticate_account!
  
  after_action :allow_docusign_iframe , only: :show

  def autocomplete_user_name
    users = account_company.users.where( ["name LIKE ?", "%#{params[:q]}%" ] )
    users = users.map { |a| { :id => "user_#{a.id}", :text => a.name, :type => "user" } }
    
    teams = account_company.teams.where( ["name LIKE ?", "%#{params[:q]}%" ] )
    teams = teams.map { |a| { :id => "team_#{a.id}", :text => a.name, :type => "team" } }

    render :json => users.inject(teams, :<<)
  end

  # GET /docu_signs
  # GET /docu_signs.json
  def index
    @docu_signs = DocuSign.where(:user => current_account.user)
    @docs_to_sign = @docu_signs.select{|doc| doc.status == DocuSign::STATUS_PROCESSING }.count
  end

  # GET /docu_signs/1
  # GET /docu_signs/1.json
  def show
    client = DocusignRest::Client.new

    @url = client.get_recipient_view(
      envelope_id: @docu_sign.envelope_key,
      name: current_account.user.name,
      email: current_account.email,
      return_url: url_for(  action: 'server_response',only_path: false )
    )

  end

  # GET /docu_signs/new
  def new
    @docu_template = DocuTemplate.new
  end

  # GET /docu_signs/1/edit
  def edit
  end

  # POST /docu_signs
  # POST /docu_signs.json
  def create
    @docu_template = DocuTemplate.new(docu_sign_params)
    @docu_template.company = account_company

    respond_to do |format|
      if @docu_template.save
        format.html { redirect_to docu_signs_path, notice: 'Docu sign was successfully created.' }
        format.json { render action: 'show', status: :created, location: @docu_sign }
      else

        puts @docu_template.errors.to_yaml
        format.html { render action: 'new' }
        format.json { render json: @docu_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /docu_signs/1
  # PATCH/PUT /docu_signs/1.json
  def update
    respond_to do |format|
      if @docu_sign.update(docu_sign_params)
        format.html { redirect_to @docu_sign, notice: 'Docu sign was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @docu_sign.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /docu_signs/1
  # DELETE /docu_signs/1.json
  def destroy
    @docu_sign.destroy
    respond_to do |format|
      format.html { redirect_to docu_signs_url }
      format.json { head :no_content }
    end
  end

  def server_response
    utility = DocusignRest::Utility.new


    if params[:event] == "signing_complete"
      client = DocusignRest::Client.new
      recipients = client.get_envelope_recipients(
        envelope_id: @docu_sign.envelope_key,
        include_tabs: true,
        include_extended: true
      )

      rcheck = recipients["signers"][0]

      if rcheck["status"]=="completed" and rcheck["name"]==current_account.user.name and rcheck["email"]==current_account.email
        @docu_sign.update_attribute(:status, DocuSign::STATUS_SIGNED)
      end
      flash[:notice] = "Thanks! Successfully signed"
      render :text => utility.breakout_path(docu_signs_url), content_type: 'text/html'
    else
      flash[:notice] = "You chose not to sign the document."
      @docu_sign.update_attribute(:status, DocuSign::STATUS_CANCELLED)
      render :text => utility.breakout_path(docu_signs_url), content_type: 'text/html'
    end
    store_docs_to_sign
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_docu_sign
      @docu_sign = DocuSign.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def docu_sign_params
      params.require(:docu_template).permit(:users, :document, :title)
    end

    def allow_docusign_iframe
      response.headers.except! 'X-Frame-Options'
    end    
end
