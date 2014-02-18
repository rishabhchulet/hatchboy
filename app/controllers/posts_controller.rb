class PostsController < ApplicationController
  
  before_filter :authenticate_account!

  def create
    @team = account_company.teams.where(id: params[:team_id]).first or not_found

    post = @team.posts.build( post_params )
    post.documents = doc_params unless doc_params.blank?

    status_code = 400
    if @team.save
      #flash[:notice] = "New team has been successfully added"
      status_code = 200
    else
      #flash[:notice] = "Error happened"
    end

    respond_to do |format|
      format.html { redirect_to team_path(params[:post][:team_id]) }
      format.json { render :layout => false, :text => {:error => post.errors.full_messages.join("\n")}.to_json, :status => status_code }
    end
  end

  def destroy
    @post = Post.where(id: params[:id]).first or not_found
    @post.destroy
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end

  private
  
  def post_params
    params.require(:post).permit(:subject, :message).merge( user: current_account.user )
  end

  def doc_params
    params.require(:post).permit(:documents => [])["documents"]
  end

end
