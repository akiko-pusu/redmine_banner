# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../lib/banner_application_hooks'

class BannerApplicationHooksTest < Test::Unit::TestCase
  
  def test_is_pass_timer_false_should_be_true
    target = BannerMessageHooks.instance
    context = {}
    Setting.plugin_redmine_banner['use_timer'] = "false"
    assert_equal true, target.is_pass_timer?(context)

  end
  
  def test_is_pass_timer_true_for_passed_time_should_be_false
    target = BannerMessageHooks.instance
    context = {}
    # Test: passed time set - should retuen false.
    Setting.plugin_redmine_banner['use_timer'] = "true"

    Setting.plugin_redmine_banner['start_ymd'] = "1999-12-31"
    Setting.plugin_redmine_banner['start_hour'] = "23"
    Setting.plugin_redmine_banner['start_min'] = "58"

    Setting.plugin_redmine_banner['end_ymd'] = "2000-12-31"
    Setting.plugin_redmine_banner['end_hour'] = "12"
    Setting.plugin_redmine_banner['end_min'] = "59"       
    assert_equal false, target.is_pass_timer?(context)   
  end
    
  def test_is_pass_timer_true_for_between_time_should_be_true
    target = BannerMessageHooks.instance
    context = {}
    Setting.plugin_redmine_banner['use_timer'] = "true"    
    
    # Test: passed time and the same range - should retuen false.
    Setting.plugin_redmine_banner['start_ymd'] = "1999-12-31"
    Setting.plugin_redmine_banner['start_hour'] = "01"
    Setting.plugin_redmine_banner['start_min'] = "01"

    Setting.plugin_redmine_banner['end_ymd'] = "1999-12-31"
    Setting.plugin_redmine_banner['end_hour'] = "01"
    Setting.plugin_redmine_banner['end_min'] = "01"       
    assert_equal false, target.is_pass_timer?(context)   

  end

  def test_is_pass_timer_rais_error
    target = BannerMessageHooks.instance
    context = {}
    Setting.plugin_redmine_banner['use_timer'] = "true"

    Setting.plugin_redmine_banner['start_ymd'] = "1999-12-31"
    Setting.plugin_redmine_banner['start_hour'] = "01"
    Setting.plugin_redmine_banner['start_min'] = "01"

    # Set 2050 (Will be thrown Argument Error)
    Setting.plugin_redmine_banner['end_ymd'] = "2050-12-31"
    Setting.plugin_redmine_banner['end_hour'] = "01"
    Setting.plugin_redmine_banner['end_min'] = "01"       
    assert_raise(ArgumentError){ target.is_pass_timer?(context) }   

  end  

end
