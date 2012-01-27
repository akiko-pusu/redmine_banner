ActionController::Routing::Routes.draw do |map|
  map.connect 'banner/preview', :controller => 'banner', :action => 'preview'
end