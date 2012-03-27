ActionController::Routing::Routes.draw do |map|
  map.connect 'banner/preview', :controller => 'banner', :action => 'preview'
  map.connect 'banner/off', :controller => 'banner', :action => 'off'
  map.connect 'projects/:project_id/banner/:action', :controller => 'issue_templates'
end