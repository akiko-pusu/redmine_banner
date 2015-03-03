Rails.application.routes.draw do 
  match 'projects/:project_id/banner/:action', :controller => 'banner', :via => [:get, :post, :patch, :put]
  match 'projects/:project_id/banner/project_banner_off', :to => 'banner#project_banner_off', :via => [:get, :post]
  match 'banner/preview', :to => 'banner#preview',:via => [:get, :post]
  match 'banner/off', :to => 'banner#off', :via => [:get, :post]
  match 'projects/:project_id/banner/preview', :to => 'banner#preview', :via => [:get, :post]
end
