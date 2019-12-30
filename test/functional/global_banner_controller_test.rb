# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class GlobalBannerControllerTest < Redmine::ControllerTest
  include Redmine::I18n
  fixtures :users

  def setup
    @controller = GlobalBannerController.new
    @request.session[:user_id] = 1 # admin

    # plugin setting
    Redmine::Plugin.register(:redmine_banner) do
      settings partial: nil,
               default: {
                 enable: 'false',
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
    @setting = GlobalBanner.find_or_default.value
  end

  def test_get_banner_settings
    get :show
    assert_response :success
    assert_select 'h2', /Redmine Banner plugin/, @response.body.to_s
  end

  def test_get_banner_settings_with_bad_format
    # set bad format
    @setting['start_ymd'] = '1999-13-40'
    @setting['start_ymd'] = '2011-1-35'
    @setting['use_timer'] = 'true'

    get :show
    assert_response :success
    assert_select 'input[type=checkbox][id=setting_use_timer][value=true]'
    assert_select 'h2', /Redmine Banner plugin/, @response.body.to_s
  end

  def test_get_banner_settings_with_good_format
    # set bad format
    @setting['start_ymd'] = '1999-12-31'
    @setting['end_ymd'] = '2001-01-05'
    @setting['use_timer'] = 'true'

    get :show
    assert_response :success
    assert_select 'input[type=checkbox][id=setting_use_timer][value=true]'
    assert_select 'h2', /Redmine Banner plugin/
  end

  def test_post_banner_settings_with_good_format
    # set good format
    now = Time.zone.today
    after_day = now + 1.day

    post :update, params: { setting: { end_ymd: after_day.strftime('%Y-%m-%d'), end_min: '03', start_min: '00', start_hour: '00',
                                       enable: 'true', type: 'warn', display_part: 'both',
                                       start_ymd: now.strftime('%Y-%m-%d'), use_timer: 'true',
                                       banner_description: 'exp. Information about upcoming Service Interruption.',
                                       end_hour: '23' } }
    assert_response :redirect
    assert_redirected_to controller: 'global_banner', action: 'show'
    assert_equal I18n.t(:notice_successful_update), flash[:notice]

    get :show
    assert_response :success
    assert_select 'div.banner_area' do
      assert_select 'div.banner_warn' do
        assert_select 'p', text: 'exp. Information about upcoming Service Interruption.'
      end
    end

    post :update, params: { setting: { end_ymd: '2012-12-31', end_min: '03', start_min: '03', start_hour: '20',
                                       enable: 'true', type: 'warn', display_part: 'both',
                                       start_ymd: '2012-03-12', use_timer: 'true',
                                       banner_description: 'exp. Information about upcoming Service Interruption.',
                                       end_hour: '23' } }
    assert_response :redirect
    get :show
    assert_response :success
    assert_select 'div.banner_area', false, 'Banner should be off.'
  end

  def test_post_banner_settings_with_bad_format
    # set bad format
    post :update, params: { setting: { end_ymd: '2010-03-31', end_min: '03', start_min: '03', start_hour: '20',
                                       enable: 'true', type: 'warn', display_part: 'both',
                                       start_ymd: '2013-03-12', use_timer: 'true',
                                       banner_description: 'exp. Information about upcoming Service Interruption.',
                                       end_hour: '23' } }
    assert_response :redirect
    assert_redirected_to controller: 'global_banner', action: 'show'
    assert_equal I18n.t(:error_banner_date_range), flash[:error]
  end

  def test_post_banner_setting_with_non_number_format
    post :update, params: { setting: { end_ymd: 'end_ymd', end_min: 'end_min', start_min: 'start_min', start_hour: 'start_hour',
                                       enable: 'true', type: 'warn', display_part: 'both',
                                       start_ymd: 'start_ymd', use_timer: 'true',
                                       banner_description: 'exp. Information about upcoming Service Interruption.',
                                       end_hour: 'end_hour' } }
    assert_response :redirect
    assert_not_nil flash[:error]
  end
end
