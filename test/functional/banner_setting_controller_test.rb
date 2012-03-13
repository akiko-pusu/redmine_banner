require File.dirname(__FILE__) + '/../test_helper'

class BannerSettingControllerTest < ActionController::TestCase
  fixtures :users
  def setup
    @controller = SettingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
    @request.session[:user_id] = 1 # admin
  end
  
  def test_get_banner_settings
    get :plugin, :id => "redmine_banner"   
    assert_response :success 
    assert_template 'settings/plugin'
    assert_select 'h2', /Redmine Banner plugin/, "#{@response.body}"
  end

  def test_get_banner_settings_with_bad_format
    # set bad format
    @plugin = Redmine::Plugin.find('redmine_banner')

    @partial = @plugin.settings[:partial]
    @settings = Setting["plugin_#{@plugin.id}"]
    @settings['start_ymd'] = "1999-13-40"
    @settings['start_ymd'] = "2011-1-35"
    @settings['use_timer'] = "true"
    
    get :plugin, :id => "redmine_banner"   
    assert_response :success 
    assert_template 'settings/plugin'
    assert_select "input#settings_use_timer" do
      assert_select "[checked='checked']", false
    end
    assert_select 'h2', /Redmine Banner plugin/, "#{@response.body}"
  end
  
  def test_get_banner_settings_with_good_format
    # set bad format
    @plugin = Redmine::Plugin.find('redmine_banner')

    @partial = @plugin.settings[:partial]
    @settings = Setting["plugin_#{@plugin.id}"]
    @settings['start_ymd'] = "1999-12-31"
    @settings['end_ymd'] = "2001-01-05"
    @settings['use_timer'] = "true"
    
    get :plugin, :id => "redmine_banner"   
    assert_response :success 
    assert_template 'settings/plugin'
    assert_select "input#settings_use_timer" do
      assert_select "[checked='checked']"
    end
    assert_select 'h2', /Redmine Banner plugin/, "#{@response.body}"
  end
end