require File.dirname(__FILE__) + '/../test_helper'

class BannerSettingControllerTest < ActionController::TestCase
  fixtures :users
  include Redmine::I18n
  def setup
    @controller = SettingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
    @request.session[:user_id] = 1 # admin
    
    # plugin setting
    @plugin = Redmine::Plugin.find('redmine_banner')
    @partial = @plugin.settings[:partial]
    @settings = Setting["plugin_#{@plugin.id}"]    
  end
  
  def test_get_banner_settings
    get :plugin, :id => "redmine_banner"   
    assert_response :success 
    assert_template 'settings/plugin'
    assert_select 'h2', /Redmine Banner plugin/, "#{@response.body}"
  end

  def test_get_banner_settings_with_bad_format
    # set bad format
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
    @settings['start_ymd'] = "1999-12-31"
    @settings['end_ymd'] = "2001-01-05"
    @settings['use_timer'] = "true"
    
    get :plugin, :id => "redmine_banner"   
    assert_response :success 
    assert_template 'settings/plugin'
    assert_select "input#settings_use_timer" do
      assert_select "[checked='checked']"
    end
    assert_select 'h2', /Redmine Banner plugin/
  end
  
  def test_post_banner_settings_with_good_format
    # set good format
    post :plugin, :id => "redmine_banner",
      :settings => {:end_ymd => "2015-03-31", :end_min => "03", :start_min => "03", :start_hour => "20", 
      :enable => "true", :type => "warn", :display_part => "both", 
      :start_ymd => "2012-03-12", :use_timer => "true",
      :banner_description => "exp. Information about upcoming Service Interruption.", 
      :end_hour => "23"}
    assert_response :redirect
    assert_redirected_to :controller => 'settings', :action => 'plugin', :id => "redmine_banner"
    assert_equal I18n.t(:notice_successful_update), flash[:notice] 
  end
  
  def test_post_banner_settings_with_bad_format
    # set bad format
    post :plugin, :id => "redmine_banner",
      :settings => {:end_ymd => "2010-03-31", :end_min => "03", :start_min => "03", :start_hour => "20", 
      :enable => "true", :type => "warn", :display_part => "both", 
      :start_ymd => "2013-03-12", :use_timer => "true",
      :banner_description => "exp. Information about upcoming Service Interruption.", 
      :end_hour => "23"}
    assert_response :redirect
    assert_redirected_to :controller => 'settings', :action => 'plugin', :id => "redmine_banner"
    assert_equal I18n.t(:error_banner_date_range), flash[:error] 
  end

  def test_post_banner_settings_with_out_of_range_format
    # set bad format
    post :plugin, :id => "redmine_banner",
      :settings => {:end_ymd => "2039-01-01", :end_min => "03", :start_min => "03", :start_hour => "20", 
      :enable => "true", :type => "warn", :display_part => "both", 
      :start_ymd => "2038-03-12", :use_timer => "true",
      :banner_description => "exp. Information about upcoming Service Interruption.", 
      :end_hour => "23"}
    assert_response :redirect
    assert_redirected_to :controller => 'settings', :action => 'plugin', :id => "redmine_banner"
    assert(flash[:error] != nil)
  end 
  
end