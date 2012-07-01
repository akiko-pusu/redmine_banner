Rails.application.routes.draw do 
  match 'projects/:project_id/banner/:action', :to => 'banner'
  match 'projects/:project_id/banner/project_banner_off', :to => 'banner#project_banner_off'
  match 'banner/preview', :to => 'banner#preview'
  match 'banner/off', :to => 'banner#off'
end