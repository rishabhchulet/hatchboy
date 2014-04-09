class DocuTemplatesController < ApplicationController

  before_action :set_docu_template, only: [ :show, :edit, :update, :destroy]
  before_filter :authenticate_account!
  
  after_action :allow_docusign_iframe  , only: :create

  def autocomplete_user_name
    team_string_id = "team_"
    user_string_id = "user_"
    
    if params[:q].start_with?(team_string_id, user_string_id)

      teams = params[:q].split(",")
      users = teams.select { |element| element.start_with?(user_string_id) }.map{|el| el.split("_")[1]}
      teams.keep_if { |element| element.start_with?(team_string_id) }.map!{|el| el.split("_")[1]}

      users = account_company.users.where(:id => users)
      teams = account_company.teams.where(:id => teams)
    else
    
      users = account_company.users.where( ["name LIKE ?", "%#{params[:q]}%" ] )
      teams = account_company.teams.where( ["name LIKE ?", "%#{params[:q]}%" ] )
    end

    users = users.map { |a| { :value => "user_#{a.id}", :text => a.name, :type => "user" } }
    teams = teams.map { |a| { :value => "team_#{a.id}", :text => a.name, :type => "team" } }

    render :json => users.inject(teams, :<<)
  end

  # GET /docu_signs
  # GET /docu_signs.json
  def index
    @docu_signs = DocuSign.where(:user => current_account.user)
    @docu_templates = DocuTemplate.includes(:docu_signs).order("created_at DESC").all
  end

  # GET /docu_templates/1
  # GET /docu_templates/1.json
  def show
    json_to_render = []

    @docu_template.docu_signs.each do |ds|
      info_class = 'success' if ds.status == DocuSign::STATUS_SIGNED
      info_class = 'important' if ds.status == DocuSign::STATUS_CANCELLED
      info_class = 'warning' if ds.status == DocuSign::STATUS_PROCESSING

      infobox = {:id => ds.id, :name => ds.user.name, :status => ds.status.upcase, :class => info_class}
      json_to_render << infobox
    end

    respond_to do |format|
        format.html
        format.json { render json:json_to_render, status: :ok }
        format.js
    end
  end

  # GET /docu_signs/new
  def new
    @docu_template = DocuTemplate.new
    @docu_template.docu_signs.build

    session.delete(:docusign)
  end

  # POST /docu_signs
  # POST /docu_signs.json
  def create

    @permit_saving = true
    @success = false

    if remotipart_submitted? and params[:docu_template][:self_sign] == "1"

      client = DocusignRest::Client.new

      document_envelope_response = client.create_envelope_from_document(
        email: {
          subject: "test email subject",
          body: "this is the email body and it's large!"
        },
        # If embedded is set to true  in the signers array below, emails
        # don't go out to the signers and you can embed the signature page in an 
        # iFrame by using the client.get_recipient_view method
        signers: [
          {
            embedded: true,
            name: current_account.user.name,
            email: current_account.email,
            role_name: 'Signer'
          },
        ],
        files: [
          { path: params[:docu_template][:document].path, name: params[:docu_template][:document].original_filename }
        ],
        status: 'sent'
      )
      
      @recipient_view = client.get_recipient_view(
        envelope_id: document_envelope_response["envelopeId"],
        name: current_account.user.name,
        email: current_account.email,
        return_url: url_for(  action: 'server_response', only_path: false )
      )

      session[:docusign] = { :status =>"created", :recipient_view => @recipient_view, :document => document_envelope_response }
      @permit_saving = false
    else
    end

    @docu_template = DocuTemplate.new(docu_template_params)
    @docu_template.company = account_company
    @docu_template.user = current_account.user
    #@docu_template.docu_signs.build if @docu_template.docu_signs.empty?

    if params[:docu_template][:self_sign] and session[:docusign] and session[:docusign][:status]=="completed"
      @docu_template.document = File.open( session[:docusign][:path] )
      @permit_saving = true
    end

    respond_to do |format|
      if @docu_template.valid? and @permit_saving
        @docu_template.save(validate: false)
        session.delete(:docusign)
        @docu_template = DocuTemplate.new
        @success = true
        
        store_docs_to_sign

        format.html { redirect_to docu_signs_path, notice: 'Docu sign was successfully created.' }
        format.json { render action: 'show', status: :created, location: @docu_template }
        format.js
      else
        puts @docu_template.errors.to_yaml
        format.html { render action: 'new' }
        format.json { render json: @docu_template.errors, status: :unprocessable_entity }
        format.js
      end

    end
  end

  # PATCH/PUT /docu_signs/1
  # PATCH/PUT /docu_signs/1.json
  def update
    respond_to do |format|
      if @docu_template.update(docu_template_params)
        format.html { redirect_to @docu_template, notice: 'Docu sign was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @docu_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /docu_signs/1
  # DELETE /docu_signs/1.json
  def destroy
    @docu_template.destroy
    respond_to do |format|
      format.html { redirect_to docu_templates_url }
      format.json { head :no_content }
    end
  end

  def server_response
    utility = DocusignRest::Utility.new

    if params[:event] == "signing_complete"
      client = DocusignRest::Client.new
      recipients = client.get_envelope_recipients(
        envelope_id: session[:docusign][:document]["envelopeId"],
        include_tabs: true,
        include_extended: true
      )

      rcheck = recipients["signers"][0]

      if rcheck["status"]=="completed" and rcheck["name"]==current_account.user.name and rcheck["email"]==current_account.email
        session[:docusign][:status] = "completed"

        client = DocusignRest::Client.new
        # Download the document
        client.get_document_from_envelope(
          envelope_id: session[:docusign][:document]["envelopeId"],
          document_id: 1,
          local_save_path: "#{Rails.root.join( 'tmp', 'docusign', session[:docusign][:document]["envelopeId"].to_s + '.pdf' )}",
          return_stream: false )

        session[:docusign][:path] = Rails.root.join( 'tmp', 'docusign', session[:docusign][:document]["envelopeId"].to_s + '.pdf' )

        render :text => "<html><body><script type='text/javascript' charset='utf-8'>window.parent.docusign_complete();</script></body></html>", content_type: 'text/html'
      end
    else
      session[:docusign][:status] = "cancelled"
      render :text => "<html><body><script type='text/javascript' charset='utf-8'>window.parent.$(window.parent.document).trigger('docusign_cancelled');</script></body></html>", content_type: 'text/html'
    end
    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_docu_template
      @docu_template = DocuTemplate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def docu_template_params
      params.require(:docu_template).permit(:recipients, :self_sign, :users, :document, :title)
    end

    def allow_docusign_iframe
      response.headers['X-Frame-Options'] = 'ALLOWALL'
    end    

end


