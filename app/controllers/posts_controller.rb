class PostsController < ApplicationController
  
  before_filter :authenticate_account!

  def show
    @post = Post.find(params[:id]) or not_found
  end

  def create
    @team = account_company.teams.where(id: params[:post][:team_id]).first or not_found
    @posts = @team.posts
    @post = @team.posts.build( post_params )

    respond_to do |format|
      if @team.save
        format.html { redirect_to @team, notice: 'User was successfully created.' }
        #format.json { render json: @post, status: :created, location: @team }
        format.js   {}
      else
        format.html { redirect_to @team, notice: 'User was not successfully created.' }
        #format.json { render json: @post.errors, status: :unprocessable_entity }
        format.js
      end
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
    params.require(:post).permit(:subject, :message, :documents => []).merge( user: current_account.user )
  end

end
