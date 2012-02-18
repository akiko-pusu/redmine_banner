class BannerController < ApplicationController
  unloadable
  before_filter :require_admin
  
  def preview
    @text = params[:settings][:banner_description]
    render :partial => 'common/preview'
  end
  
  def off
    begin
      @plugin = Redmine::Plugin.find("redmine_banner")
      @settings = Setting["plugin_#{@plugin.id}"]
      @settings["enable"] = "false"
      Setting["plugin_#{@plugin.id}"] = @settings
      render :text => "<script type=\"text/javascript\">hideBanner();</script>"
    rescue
      render :text => ""
    end  
  end

  def show
  end
end
