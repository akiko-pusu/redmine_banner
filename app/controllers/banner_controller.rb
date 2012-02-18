class BannerController < ApplicationController
  unloadable
  before_filter :require_admin
  
  def preview
    @text = params[:settings][:banner_description]
    render :partial => 'common/preview'
  end
  
  def off
    @plugin = Redmine::Plugin.find("redmine_banner")
    @settings = Setting["plugin_#{@plugin.id}"]
    @settings["enable"] = "false"
    Setting["plugin_#{@plugin.id}"] = @settings
    render :text => "<script type=\"text/javascript\">hideBanner();</script>"
  end

  def show
  end
end
