require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require 'projects_controller'

# Re-raise errors caught by the controller.
class ProjectsController; def rescue_action(e)
                            raise e
                          end
end

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
    @project.enabled_modules << EnabledModule.new(name: 'banner')
    @project.save!

    @banner = Banner.find_or_create(1)
    @banner.display_part = 'overview'
    @banner.enabled = true
    @banner.save!
  end

  def test_settings
    get :settings, id: 1
    assert_response :success
    assert_template 'settings'
    assert_select 'a#tab-banner'
    assert_select 'div.project_banner_area div.banner_info', false,
                  'Banner should be displayed Overview only.'
  end

  # project 1 is enabled banner and type is info, display_part is overview only.
  def test_show_overview
    get :show, id: 1
    assert_response :success
    assert_select 'div.project_banner_area div.banner_info'
  end

  def test_show_all
    @banner.display_part = 'all'
    @banner.style = 'warn'
    @banner.save!
    get :settings, id: 1
    assert_response :success
    assert_select 'div.project_banner_area div.banner_warn'
  end

  def test_show_overview_and_issues
    @banner.display_part = 'overview_and_issues'
    @banner.style = 'alert'
    @banner.save!
    get :show, id: 1
    assert_response :success
    assert_select 'div.project_banner_area div.banner_alert'
  end

  def test_show_unknown_display_part
    @banner.display_part = 'unknown_display_part'
    @banner.style = 'normal'

    assert_raise(ActiveRecord::RecordInvalid) { @banner.save! }
    get :show, id: 1
    assert_response :success
    assert_select 'div.project_banner_area div.banner_normal', false
  end

  def test_show_new_issue
    @banner.display_part = 'new_issue'
    @banner.style = 'alert'
    @banner.save!
    get :show, id: 1
    assert_response :success
    assert_select 'div.project_banner_area div.banner_alert', false
  end

  def test_banner_should_be_off_with_banner_module_disabled
    @banner.display_part = 'all'
    @banner.style = 'warn'
    @banner.save!
    # turn off banner module
    @project.disable_module!(:banner)
    assert !@project.reload.enabled_module_names.include?(:banner)

    get :settings, id: 1
    assert_response :success
    assert_select 'div.project_banner_area div.banner_warn', false,
                  'Banner should not be displayed when module is diabled!'
  end
end
