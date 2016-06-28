require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class BannerTest < ActiveSupport::TestCase
  fixtures :projects, :banners

  def setup
    @banner = Banner.find(1)
  end

  def test_truth
    assert_kind_of Banner, @banner
  end

  def test_banner_enabled
    enabled = @banner.enable_banner?
    assert_equal true, enabled, @banner.enable_banner?

    @banner.enabled = false
    @banner.save!
    enabled = @banner.enable_banner?
    assert_equal false, enabled, @banner.enable_banner?
  end

  def test_duplicate_project_setting_with_safe_attributes
    banner = Banner.find_or_create(2)
    assert_equal 2, banner.project.id
    banner.safe_attributes = { project_id: 1 }
    # safe_attributes prevent overwrite project id.
    assert banner.save, 'Safe attribute settings has something wrong.'
    assert_equal 2, banner.project.id
  end

  def test_banner_find_or_create
    banner = Banner.find_or_create(2)
    banner.destroy
    banner = Banner.find_or_create(2)
    assert_equal false, banner.enabled
  end
end
