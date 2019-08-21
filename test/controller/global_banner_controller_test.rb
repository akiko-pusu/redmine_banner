# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)
class GlobalBannerControllerTest < Redmine::IntegrationTest
  fixtures :users

  def setup
    @user = User.find_by_login('admin')

    @banner_admin_group = Group.create(name: 'GlobalBanner_Admin')
    @non_admin_user = User.find(2)
  end

  def test_routing
    assert_routing({ path: '/banners/api/global_banner', method: :get }, controller: 'banners/api/global_banner', action: 'show')
    assert_routing({ path: '/banners/api/global_banner', method: :put }, controller: 'banners/api/global_banner', action: 'register_banner')
  end

  # Case Admin
  def test_get_global_banner_when_api_disable
    Setting.rest_api_enabled = '0'
    get '/banners/api/global_banner.json', headers: { 'X-Redmine-API-Key' => @user.api_key }
    assert_response 403
  end

  def test_get_global_banner_when_api_enable
    Setting.rest_api_enabled = '1'
    get '/banners/api/global_banner.json', headers: { 'X-Redmine-API-Key' => @user.api_key }
    assert_response :success
  end

  # Case non-admin user (jsmith)
  def test_get_global_banner_when_api_enable_and_non_banner_admin_group
    Setting.rest_api_enabled = '1'
    get '/banners/api/global_banner.json', headers: { 'X-Redmine-API-Key' => @non_admin_user.api_key }
    assert_response 401
  end

  def test_get_global_banner_when_api_enable_and_banner_admin_group
    Setting.rest_api_enabled = '1'

    @banner_admin_group.user_ids = [@non_admin_user.id]
    @banner_admin_group.save!

    get '/banners/api/global_banner.json', headers: { 'X-Redmine-API-Key' => @non_admin_user.api_key }
    assert_response :success
  end

  def test_put_global_banner_when_api_enable_and_banner_admin_group_and_empty_data
    Setting.rest_api_enabled = '1'

    @banner_admin_group.user_ids = [@non_admin_user.id]
    @banner_admin_group.save!

    put '/banners/api/global_banner.json', params: { "global_banner": {} }, as: :json,
                                           headers: { 'X-Redmine-API-Key' => @non_admin_user.api_key }
    assert_response 400
  end

  def test_put_global_banner_when_api_enable_and_banner_admin_group_and_valid_data
    Setting.rest_api_enabled = '1'

    @banner_admin_group.user_ids = [@non_admin_user.id]
    @banner_admin_group.save!

    global_banner = {
      "banner_description": 'Test message',
      "display_part": 'both',
      "enable": 'true'
    }

    put '/banners/api/global_banner.json', params: { "global_banner": global_banner }, as: :json,
                                           headers: { 'X-Redmine-API-Key' => @non_admin_user.api_key }
    assert_response :success
  end
end
