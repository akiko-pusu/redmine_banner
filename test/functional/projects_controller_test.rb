require File.expand_path('../../test_helper', __FILE__)
require 'projects_controller'

# Re-raise errors caught by the controller.
class ProjectsController; def rescue_action(e) raise e end; end

class ProjectsControllerTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :members, :member_roles,
           :trackers, :projects_trackers, :enabled_modules, :banners
  def setup
    @controller = ProjectsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    # as project admin
    @request.session[:user_id] = 2
    Role.find(1).add_permission! :manage_banner
    # Enabled Banner module
    @project = Project.find(1)
    @project.enabled_modules << EnabledModule.new(:name => 'banner')
    @project.save!

    @banner = Banner.find_or_create(1)
    @banner.display_part = "overview"
    @banner.save!
  end
  
  def test_settings
    get :settings, :id => 1
    assert_response :success
    assert_template 'settings'
    assert_select 'a#tab-banner'
    assert_select 'div#project_banner_area div.banner_info', false, 'Banner should be displayed Overview only.'
  end

  # project 1 is enabled banner and type is info, display_part is overview only.
  def test_show_overview
    get :show, :id => 1
    assert_response :success
    assert_select 'div#project_banner_area div.banner_info'    
  end

  
end

