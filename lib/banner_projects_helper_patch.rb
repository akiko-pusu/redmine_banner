# To change this template, choose Tools | Templates
# and open the template in the editor.
require_dependency 'projects_helper'

module BannerProjectsHelperPatch
  def self.included base # :nodoc:
    base.send :include, ProjectsHelperMethodsBanner
    base.class_eval do
      alias_method_chain :project_settings_tabs, :banner
    end
  end
end

module ProjectsHelperMethodsBanner
  def project_settings_tabs_with_banner
    tabs = project_settings_tabs_without_banner
    action = {:name => 'banner', 
      :controller => 'banner',
      :action => :show, 
      :partial => 'banner/show', :label => :banner}
    tabs << action if User.current.allowed_to?(action, @project)
    tabs
  end
end
