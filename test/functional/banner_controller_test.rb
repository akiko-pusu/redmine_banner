require File.dirname(__FILE__) + '/../test_helper'

class BannerControllerTest < ActionController::TestCase
  def setup
    User.current = nil
    @request.session[:user_id] = 1 # Do test as admin
  end  
  
  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  test "should off banner" do
    get :off
    assert_response :success, "returned #{@response}"
    assert_equal "false", Setting.plugin_redmine_banner['enable']
  end
  
  test "routing check" do
    assert_generates('banner/preview', { :controller => 'banner', :action => 'preview'})
    assert_generates('banner/off', { :controller => 'banner', :action => 'off'})
  end
  
  test "should preview banner" do
    get :preview, {:settings => {:banner_description=> "h1. Test data."}}
    assert_template "common/_preview.html.erb"
    assert_select 'h1', /Test data\./, "#{@response.body}"
  end
end
