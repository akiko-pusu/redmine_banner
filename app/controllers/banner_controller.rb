class BannerController < ApplicationController
  unloadable
  before_filter :require_admin, :only => [:off]
  before_filter :find_user, :find_project, :authorize, :except => [ :preview, :off ]
  
  def preview
    @text = params[:settings][:banner_description]
    render :partial => 'common/preview'
  end
  
  def banner_preview
    @text = params[:settings][:description]
    render :partial => 'common/preview'
  end
  
  def off
    begin
      @plugin = Redmine::Plugin.find("redmine_banner")
      @settings = Setting["plugin_#{@plugin.id}"]
      @settings["enable"] = "false"
      Setting["plugin_#{@plugin.id}"] = @settings
      render :text => ""
    rescue Exception => exc
      logger.warn("Message for the log file / When off banner #{exc.message}")
      render :text => ""
    end  
  end

  def show
    @banner = Banner.find_or_create(@project.id)
  end
  
  def edit
    if (params[:settings] != nil)
      @banner = Banner.find_or_create(@project.id)
      @banner.safe_attributes = params[:settings]
      @banner.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to :controller => 'projects', 
        :action => "settings", :id => @project, :tab => 'banner'
    end    
  end
  
  private
  def find_user
    @user = User.current
  end

  def find_project
    begin
      @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
  
end
