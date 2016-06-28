require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class BannerHelperTest < ActiveSupport::TestCase
  include BannerHelper

  def test_get_time
    y = '2012'
    m = '12'
    d = '31'
    h = '11'
    min = '59'
    ymd = "#{y}-#{m}-#{d}"
    t = Time.mktime(y, m, d, h, min)
    assert_equal true, t == get_time(ymd, h, min)
  end

  # This should not be happened in 64bit.
  #  def test_get_time_rais_error
  #    y = "2050"
  #    m = "12"
  #    d = "31"
  #    h = "11"
  #    min = "59"
  #    assert_raise(ArgumentError){ get_time("#{y}-#{m}-#{d}",h,min)  }
  #  end
end
