require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

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
    get :plugin, id: 'redmine_banner'
    assert_response :success
    assert_template 'settings/plugin'
    assert_select 'h2', /Redmine Banner plugin/, @response.body.to_s
  end

  def test_get_banner_settings_with_bad_format
    # set bad format
    @settings['start_ymd'] = '1999-13-40'
    @settings['start_ymd'] = '2011-1-35'
    @settings['use_timer'] = 'true'

    get :plugin, id: 'redmine_banner'
    assert_response :success
    assert_template 'settings/plugin'
    assert_select 'input[type=checkbox][id=settings_use_timer][value=true]'
    assert_select 'h2', /Redmine Banner plugin/, @response.body.to_s
  end

  def test_get_banner_settings_with_good_format
    # set bad format
    @settings['start_ymd'] = '1999-12-31'
    @settings['end_ymd'] = '2001-01-05'
    @settings['use_timer'] = 'true'

    get :plugin, id: 'redmine_banner'
    assert_response :success
    assert_template 'settings/plugin'
    assert_select 'input[type=checkbox][id=settings_use_timer][value=true]'
    assert_select 'h2', /Redmine Banner plugin/
  end

  def test_post_banner_settings_with_good_format
    # set good format
    now = Date.today
    after_day = now + 1

    post :plugin, id: 'redmine_banner',
                  settings: { end_ymd: after_day.strftime('%Y-%m-%d'), end_min: '03', start_min: '00', start_hour: '00',
                              enable: 'true', type: 'warn', display_part: 'both',
                              start_ymd: now.strftime('%Y-%m-%d'), use_timer: 'true',
                              banner_description: 'exp. Information about upcoming Service Interruption.',
                              end_hour: '23' }
    assert_response :redirect
    assert_redirected_to controller: 'settings', action: 'plugin', id: 'redmine_banner'
    assert_equal I18n.t(:notice_successful_update), flash[:notice]

    get :plugin, id: 'redmine_banner'
    assert_response :success
    assert_select 'div.banner_area' do
      assert_select 'div.banner_warn' do
        assert_select 'p', text: 'exp. Information about upcoming Service Interruption.'
      end
    end

    post :plugin, id: 'redmine_banner',
                  settings: { end_ymd: '2012-12-31', end_min: '03', start_min: '03', start_hour: '20',
                              enable: 'true', type: 'warn', display_part: 'both',
                              start_ymd: '2012-03-12', use_timer: 'true',
                              banner_description: 'exp. Information about upcoming Service Interruption.',
                              end_hour: '23' }
    assert_response :redirect
    get :plugin, id: 'redmine_banner'
    assert_response :success
    assert_select 'div.banner_area', false, 'Banner should be off.'
  end

  def test_post_banner_settings_with_bad_format
    # set bad format
    post :plugin, id: 'redmine_banner',
                  settings: { end_ymd: '2010-03-31', end_min: '03', start_min: '03', start_hour: '20',
                              enable: 'true', type: 'warn', display_part: 'both',
                              start_ymd: '2013-03-12', use_timer: 'true',
                              banner_description: 'exp. Information about upcoming Service Interruption.',
                              end_hour: '23' }
    assert_response :redirect
    assert_redirected_to controller: 'settings', action: 'plugin', id: 'redmine_banner'
    assert_equal I18n.t(:error_banner_date_range), flash[:error]
  end

  def test_post_banner_setting_with_non_number_format
    post :plugin, id: 'redmine_banner',
                  settings: { end_ymd: 'end_ymd', end_min: 'end_min', start_min: 'start_min', start_hour: 'start_hour',
                              enable: 'true', type: 'warn', display_part: 'both',
                              start_ymd: 'start_ymd', use_timer: 'true',
                              banner_description: 'exp. Information about upcoming Service Interruption.',
                              end_hour: 'end_hour' }
    assert_response :redirect
    assert_not_nil flash[:error]
  end
end
