require File.expand_path('../../test_helper', __FILE__)
require 'projects_controller'

# Re-raise errors caught by the controller.
class ProjectsController; def rescue_action(e) raise e end; end

class ProjectsControllerTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :members, :member_roles,
           :trackers, :projects_trackers, :enabled_modules
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
  end
  
  def test_settings
    get :settings, :id => 1
    assert_response :success
    assert_template 'settings'
    assert_select 'a#tab-banner'
  end  
end

