ActionController::Routing::Routes.draw do |map|
  map.connect 'banner/preview', :controller => 'banner', :action => 'preview'
  map.connect 'banner/off', :controller => 'banner', :action => 'off'
  map.connect 'projects/:project_id/banner/:action', :controller => 'banner'
  map.connect 'projects/:project_id/banner/project_banner_off', :controller => 'banner', :action => 'project_banner_off'
end