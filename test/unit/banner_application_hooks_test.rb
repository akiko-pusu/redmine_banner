# frozen_string_literal: true

# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../lib/banners/application_hooks')

class BannerApplicationHooksTest < ActiveSupport::TestCase
  def test_is_pass_timer_false_should_be_true
    target = Banners::BannerMessageHooks.instance
    global_banner = GlobalBanner.find_or_default
    Setting.plugin_redmine_banner['use_timer'] = 'false'
    assert_equal true, target.pass_timer?(global_banner)
  end

  def test_is_pass_timer_true_for_passed_time_should_be_false
    target = Banners::BannerMessageHooks.instance

    params = {
      'use_timer': 'true',
      'start_ymd': '1999-12-31',
      'start_hour': '23',
      'start_min': '58',
      'end_ymd': '2000-12-31',
      'end_hour': '12',
      'end_min': '59'
    }

    global_banner = GlobalBanner.find_or_default
    global_banner.merge_value(params)
    global_banner.save
    assert_equal false, target.pass_timer?(global_banner.reload)
  end

  def test_is_pass_timer_true_for_between_time_should_be_true
    target = Banners::BannerMessageHooks.instance

    # Test: passed time and the same range - should retuen false.
    params = {
      'use_timer': 'true',
      'start_ymd': '1999-12-31',
      'start_hour': '01',
      'start_min': '01',
      'end_ymd': '2000-12-31',
      'end_hour': '01',
      'end_min': '01'
    }

    global_banner = GlobalBanner.find_or_default
    global_banner.merge_value(params)
    global_banner.save

    assert_not(target.pass_timer?(global_banner.reload))
  end
end
