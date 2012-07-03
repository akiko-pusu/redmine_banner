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

  def setup
    # plugin setting
    @settings = Setting.send "plugin_redmine_banner"
    @settings["enable"] = "true"
    @project = Project.find(1)
    @project.enabled_modules << EnabledModule.new(:name => 'banner')
    @project.save!

    @banner = Banner.find_or_create(1)
    @banner.display_part = "new_issue"
    @banner.style = "alert"
    @banner.enabled = true
    @banner.save!    
 
  end

  def test_project_banner_not_visible_when_issue_index_page
    log_user('jsmith', 'jsmith')
    get '/projects/ecookbook/issues'
    assert_select 'div#project_banner_area div.banner_alert', false 
  end

  def test_project_banner_visible_when_issue_new_page
    log_user('jsmith', 'jsmith')
    get '/projects/ecookbook/issues/new'
    assert_select 'div#project_banner_area'
    #assert_select 'div#project_banner_area div.banner_alert'
    #assert_select 'div#project_banner_area div.banner_info', false
  end
end