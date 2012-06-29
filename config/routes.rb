#ActionController::Routing::Routes.draw do |map|
#  map.connect 'banner/preview', :controller => 'banner', :action => 'preview'
#  map.connect 'banner/off', :controller => 'banner', :action => 'off'
#  map.connect 'projects/:project_id/banner/:action', :controller => 'banner'
#  map.connect 'projects/:project_id/banner/project_banner_off', :controller => 'banner', :action => 'project_banner_off'
#end

Rails.application.routes.draw do 
#  match 'projects/:project_id/issue_templates/:action', :to => 'issue_templates'
  match 'projects/:project_id/banner/:action', :to => 'banner'
  match 'projects/:project_id/banner/project_banner_off', :to => 'banner#project_banner_off'
  
  
#  match 'projects/:project_id/issue_templates/:action/:id', :to => 'issue_templates#edit'
#  match 'projects/:project_id/issue_templates_settings/:action', :to => 'issue_templates_settings'
  
#  match 'issue_templates/preview/:id', :to => 'issue_templates#preview'
  match 'banner/preview', :to => 'banner#preview'
  match 'banner/off', :to => 'banner#off'
#  match 'projects/:project_id/issue_templates_settings/preview', :to => 'issue_templates_settings#preview', :via => [:get, :post]
end