require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class LayoutTest < ActionController::IntegrationTest
  fixtures :projects, :trackers, :issue_statuses, :issues,
           :enumerations, :users, :issue_categories,
           :projects_trackers,
           :roles,
           :member_roles,
           :members,
           :enabled_modules,
           :workflows, 
           :banners

  def test_project_banner_not_visible_when_module_off
    # style info, enabled true, display_part: overview, module -> disabled
    
    get '/projects/ecookbook/issues'
    assert_response :success
    assert_select 'div#project_banner_area div.banner_info', 0
    
    get '/projects/ecookbook'
    assert_response :success
  end

  def test_project_banner_visible_when_module_on
    log_user('admin', 'admin')
    get '/projects/ecookbook/settings'
    assert_response :success
    post '/projects/ecookbook/modules',
      :enabled_module_names => ['issue_tracking',  'banner'], :commit => 'Save', :id => 'ecookbook'
      
    # overview page  
    get '/projects/ecookbook'   
    assert_select 'div#project_banner_area div.banner_info'
    
    get '/projects/ecookbook/issues'   
    assert_select 'div#project_banner_area div.banner_info', 0
       
    put '/projects/ecookbook/banner/edit', 
      :settings => {:enabled =>"1", :style => "warn", :display_part => "all",:banner_description => "Test banner message."}, 
      :project_id => "ecookbook"
    assert_response :redirect  

    get '/projects/ecookbook/issues'   
    assert_select 'div#project_banner_area div.banner_warn'      
  end       
end