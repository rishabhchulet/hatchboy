class HelpLinksController < ApplicationController
  before_filter :check_session!
  before_action :set_routes, only: [ :index, :new, :create, :edit, :update ]

  def index
    @help_links = HelpLink.all
  end

  def tutorials
    @help_links = HelpLink.where.not(video_link: "").all
  end

  def new
    @help_link = HelpLink.new
  end

  def create
    @help_link = HelpLink.create(help_link_params)
    if @help_link.valid?
      flash[:notice] = "New help link has been successfully added"
      redirect_to help_links_path
    else
      render "help_links/new"
    end
  end

  def edit
    @help_link = HelpLink.where(id: params[:id]).first or not_found
  end

  def update
    @help_link = HelpLink.where(id: params[:id]).first or not_found

    if @help_link.update_attributes(help_link_params)
      flash[:notice] = "Information about help link has been successfully updated"
      redirect_to help_links_path
    else
      render "help_links/edit"
    end
  end

  def destroy
    @help_link = HelpLink.where(id: params[:id]).first or not_found
    @help_link.destroy
    redirect_to help_links_path
  end

  private

    def set_routes
      @routes ||= Rails.application.routes.routes.select{|route| route.defaults[:controller] and %w{ GET }.grep(route.verb).count > 0 and !route.path.spec.to_s.match(/^\/rails/)}.map do |route|
        {
          path: route.path.spec.to_s.gsub(/\(\.:format\)/, ""),
          controller: route.defaults[:controller],
          action: route.defaults[:action]
        }
      end
    end

  def help_link_params
    params.require(:help_link).permit(:controller, :action, :link, :video_link, :video_title)
  end
end