# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../lib/banner_application_hooks')

class BannerApplicationHooksTest < ActiveSupport::TestCase
  def test_is_pass_timer_false_should_be_true
    target = BannerMessageHooks.instance
    context = {}
    Setting.plugin_redmine_banner['use_timer'] = 'false'
    assert_equal true, target.is_pass_timer?(context)
  end

  def test_is_pass_timer_true_for_passed_time_should_be_false
    target = BannerMessageHooks.instance
    context = {}
    # Test: passed time set - should retuen false.
    Setting.plugin_redmine_banner['use_timer'] = 'true'

    Setting.plugin_redmine_banner['start_ymd'] = '1999-12-31'
    Setting.plugin_redmine_banner['start_hour'] = '23'
    Setting.plugin_redmine_banner['start_min'] = '58'

    Setting.plugin_redmine_banner['end_ymd'] = '2000-12-31'
    Setting.plugin_redmine_banner['end_hour'] = '12'
    Setting.plugin_redmine_banner['end_min'] = '59'
    assert_equal false, target.is_pass_timer?(context)
  end

  def test_is_pass_timer_true_for_between_time_should_be_true
    target = BannerMessageHooks.instance
    context = {}
    Setting.plugin_redmine_banner['use_timer'] = 'true'

    # Test: passed time and the same range - should retuen false.
    Setting.plugin_redmine_banner['start_ymd'] = '1999-12-31'
    Setting.plugin_redmine_banner['start_hour'] = '01'
    Setting.plugin_redmine_banner['start_min'] = '01'

    Setting.plugin_redmine_banner['end_ymd'] = '1999-12-31'
    Setting.plugin_redmine_banner['end_hour'] = '01'
    Setting.plugin_redmine_banner['end_min'] = '01'
    assert(!target.is_pass_timer?(context))
  end

  # This should not be happened in 64bit.
  #  def test_is_pass_timer_rais_error
  #    target = BannerMessageHooks.instance
  #    context = {}
  #    Setting.plugin_redmine_banner['use_timer'] = "true"
  #
  #    Setting.plugin_redmine_banner['start_ymd'] = "1999-12-31"
  #    Setting.plugin_redmine_banner['start_hour'] = "01"
  #    Setting.plugin_redmine_banner['start_min'] = "01"
  #
  #    # Set 2050 (Will be thrown Argument Error)
  #    Setting.plugin_redmine_banner['end_ymd'] = "2050-12-31"
  #    Setting.plugin_redmine_banner['end_hour'] = "01"
  #    Setting.plugin_redmine_banner['end_min'] = "01"
  #    assert_raise(ArgumentError){ target.is_pass_timer?(context) }
  #  end

  def test_should_not_display_header?
    target = BannerMessageHooks.instance
    context = {}
    Setting.plugin_redmine_banner['enable'] = 'true'
    Setting.plugin_redmine_banner['display_part'] = 'footer'
    Setting.plugin_redmine_banner['use_timer'] = 'false'
    assert(!target.should_display_header?(context))
  end

  def test_should_display_header?
    target = BannerMessageHooks.instance
    context = {}
    Setting.plugin_redmine_banner['enable'] = 'true'
    Setting.plugin_redmine_banner['display_part'] = 'header'
    Setting.plugin_redmine_banner['use_timer'] = 'false'
    assert(target.should_display_header?(context))

    # between test
    now = Time.now
    start_time = now - 60 * 60 * 24
    end_time = now + 60 * 60 * 24
    Setting.plugin_redmine_banner['use_timer'] = 'true'
    Setting.plugin_redmine_banner['start_ymd'] = start_time.strftime('%Y-%m-%d')
    Setting.plugin_redmine_banner['start_hour'] = start_time.strftime('%H')
    Setting.plugin_redmine_banner['start_min'] = start_time.strftime('%M')

    Setting.plugin_redmine_banner['end_ymd'] = end_time.strftime('%Y-%m-%d')
    Setting.plugin_redmine_banner['end_hour'] = end_time.strftime('%H')
    Setting.plugin_redmine_banner['end_min'] = end_time.strftime('%M')
    assert(target.should_display_header?(context))
  end

  def test_should_display_footer?
    target = BannerMessageHooks.instance
    context = {}
    Setting.plugin_redmine_banner['enable'] = 'true'
    Setting.plugin_redmine_banner['display_part'] = 'header'
    Setting.plugin_redmine_banner['use_timer'] = 'false'
    assert(!target.should_display_footer?(context))
  end
end
