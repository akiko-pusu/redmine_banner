require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class LayoutTest < Redmine::IntegrationTest
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
    assert_select 'div.project_banner_area div.banner_info', 0

    get '/projects/ecookbook'
    assert_response :success
  end

  def test_project_banner_visible_when_module_on
    log_user('admin', 'admin')
    post '/projects/ecookbook/modules',
         enabled_module_names: %w(issue_tracking banner), commit: 'Save', id: 'ecookbook'

    # overview page
    get '/projects/ecookbook'
    assert_select 'div.project_banner_area div.banner_info'

    get '/projects/ecookbook/issues'
    assert_select 'div.project_banner_area div.banner_info', 0

    put '/projects/ecookbook/banner/edit',
        settings: { enabled: '1', style: 'warn', display_part: 'all', banner_description: 'Test banner message.' },
        project_id: 'ecookbook'
    assert_response :redirect

    get '/projects/ecookbook/issues'
    assert_select 'div.project_banner_area div.banner_warn'
  end

  ### test for global banner
  def test_display_only_for_login_page
    User.current = nil
    log_user('admin', 'admin')

    post '/settings/plugin/redmine_banner',
         settings: {
           enable: 'true', type: 'warn', display_part: 'both',
           use_timer: 'false',
           banner_description: 'h1. Test data.',
           display_only_login_page: 'true'
         }

    # Session is cleared
    reset!
    User.current = nil

    get '/login'
    assert_select 'div.banner_area'
    get '/projects'
    assert_select 'div.banner_area', 0

    log_user('admin', 'admin')
    post '/settings/plugin/redmine_banner',
         settings: {
           enable: 'true', type: 'warn', display_part: 'both',
           use_timer: 'false',
           banner_description: 'h1. Test data.',
           display_only_login_page: 'true',
           only_authenticated: 'true'
         }

    # Session is cleared
    reset!
    User.current = nil

    get '/login'
    assert_select 'div.banner_area', 0
    get '/projects'
    assert_select 'div.banner_area', 0
  end

  ### test for global banner / More Link
  def test_display_more_link
    User.current = nil
    log_user('admin', 'admin')

    post '/settings/plugin/redmine_banner',
         settings: {
           enable: 'true', type: 'warn', display_part: 'both',
           use_timer: 'false',
           banner_description: 'h1. Test data.',
           display_only_login_page: 'false',
           only_authenticated: 'false',
           related_link: ''
         }

    get '/'
    assert_select 'div.banner_more_info', 0

    # Update setting.
    post '/settings/plugin/redmine_banner',
         settings: {
           enable: 'true', type: 'warn', display_part: 'both',
           use_timer: 'false',
           banner_description: 'h1. Test data.',
           display_only_login_page: 'false',
           only_authenticated: 'false',
           related_link: 'http://www.redmine.org/'
         }

    # Should include more link.
    get '/'
    assert_select 'div.banner_more_info'
    assert_select 'div.banner_more_info a[href="http://www.redmine.org/"]'
  end
end
