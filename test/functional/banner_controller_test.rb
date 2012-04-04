require File.dirname(__FILE__) + '/../test_helper'
class BannerControllerTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :trackers, :members, :member_roles, :enabled_modules, :banners
  def setup
    User.current = nil
    @request.session[:user_id] = 1 # Do test as admin
    @settings = Setting["plugin_redmine_banner"]
    @settings["enable"] = "true";
  end  
  
  test "should off banner" do
    get :off
    assert_response :success, "returned #{@response}"
    assert_equal "false", @settings["enable"]
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
  
  ### test for project banner
  context "#project_banner" do
    setup do
      @request.session[:user_id] = 2
      @response   = ActionController::TestResponse.new
      @request.env["HTTP_REFERER"] = '/'
      # Enabled Banner module
      @project = Project.find(1)
      @project.enabled_modules << EnabledModule.new(:name => 'banner')
      @project.save!
    end
    
    should "edit without manage permission return 403" do
      Role.find(1).remove_permission! :manage_banner
      post :edit, :project_id => 1, 
        :settings => { :enabled => "1", :description => "Edit test", :use_timer => false, 
        :display_part => "all", :style => 'alert'}
      assert_response 403
    end
    
    should "banner_off without manage permission return 403" do
      Role.find(1).remove_permission! :manage_banner
      post :banner_off, :project_id => 1
      assert_response 403
    end
    

    context "with permission" do	
      setup do
        Role.find(1).add_permission! :manage_banner
        @project = Project.find 1
      end

      should "non existing project return 404" do
        # set non existing project
        post :edit, :project_id => 100, 
          :settings => { :enabled => "1", :description => "Edit test", :use_timer => false, 
          :display_part => "all", :style => 'alert'}
        assert_response 404        
      end
      
      should "redirect post" do
        post :edit, :project_id => 1, 
          :settings => { :enabled => "1", :description => "Edit test", :use_timer => false, 
          :display_part => "all", :style => 'alert'}
        assert_response :redirect          
        assert_redirected_to :controller => 'projects', 
          :action => "settings", :id => @project, :tab => 'banner'
      end      
    end
  end
end