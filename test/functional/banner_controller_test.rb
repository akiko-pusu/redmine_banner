# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)
class BannerControllerTest < Redmine::ControllerTest
  fixtures :projects, :users, :roles, :trackers, :members, :member_roles,
           :enabled_modules, :banners
  def setup
    User.current = nil

    Redmine::Plugin.register(:redmine_banner) do
      settings partial: 'settings/redmine_banner',
               default: {
                 enable: 'true',
                 banner_description: 'exp. Information about upcoming Service Interruption.',
                 type: 'info',
                 display_part: 'both',
                 use_timer: 'false',
                 start_ymd: nil,
                 start_hour: nil,
                 start_min: nil,
                 end_ymd: nil,
                 end_hour: nil,
                 end_min: nil,
                 related_link: nil
               }
    end
    @settings = Setting['plugin_redmine_banner']

    @project = Project.find(1)
    @project.enabled_modules << EnabledModule.new(name: 'banner')
    @project.save!
  end

  def test_banner_off_with_nologin_return_required_login
    get :off, xhr: true
    assert_response 401
  end

  def test_off_banner
    @request.session[:user_id] = 1 # Do test as admin
    get :off, xhr: true
    assert_response :success
  end

  def test_routing_check
    assert_generates('banner/preview', controller: 'banner', action: 'preview')
    assert_generates('banner/off', controller: 'banner', action: 'off')
  end

  def test_preview_banner
    get :preview, params: { setting: { banner_description: 'h1. Test data.' } }
    assert_select 'h1', /Test data\./, @response.body.to_s
  end

  ### test for project banner
  def test_edit_without_manage_permission_return_403
    @request.session[:user_id] = 2
    @request.env['HTTP_REFERER'] = '/'
    # Enabled Banner module

    Role.find(1).remove_permission! :manage_banner
    post :edit, params: { project_id: 1,
                          settings: { enabled: '1', description: 'Edit test', use_timer: false,
                                      display_part: 'all', style: 'alert' } }
    assert_response 403
  end

  def test_banner_off_without_manage_permission_return_403
    @request.session[:user_id] = 2
    Role.find(1).remove_permission! :manage_banner
    post :project_banner_off, params: { project_id: 1 }
    assert_response 403
  end

  def test_non_existing_project_return_404
    @request.session[:user_id] = 2
    Role.find(1).add_permission! :manage_banner
    @project = Project.find 1

    # set non existing project
    post :edit, params: { project_id: 100,
                          settings: { enabled: '1', description: 'Edit test', use_timer: false,
                                      display_part: 'all', style: 'alert' } }
    assert_response 404
  end

  def test_redirect_post
    @request.session[:user_id] = 1
    post :edit, params: { project_id: 1,
                          setting: { enabled: '1', description: 'Edit test',
                                     display_part: 'all', style: 'alert' } }
    assert_response :redirect
    assert_redirected_to controller: 'banner', action: 'show'
  end

  def test_return_success_when_banner_off_with_manage_permission
    @request.session[:user_id] = 2
    Role.find(1).add_permission! :manage_banner
    get :project_banner_off, params: { project_id: 1 }, xhr: true
    assert_response :success
  end

  def test_return_404_when_banner_off_without_manage_permission_with_non_existing_project
    @request.session[:user_id] = 2
    get :project_banner_off, params: { project_id: 100 }, xhr: true
    assert_response 404
  end
end
