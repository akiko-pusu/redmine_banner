require File.dirname(__FILE__) + '/../test_helper'

class BannerControllerTest < ActionController::TestCase
#  fixtures :users
  fixtures :projects, 
    :users, 
    :roles, 
    :members, 
    :member_roles, 
    :enabled_modules, 
    :issue_templates
  
  def setup
  end
  
  context "#admin" do
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
end
  
  context "#project_admin" do
    context "with permission" do
      setup do
        @request.session[:user_id] = 2
        # Enabled Template module
        @project = Project.find(1)
        @project.enabled_modules << EnabledModule.new(:name => 'issue_templates')
        @project.save!          
        Role.find(1).add_permission! :manage_banner          
      end

      should "redirect post" do
        post :edit, :project_id => @project, 
          :settings => { :enabled => true, :display_part => 'overview', :description => 'display test'}, :tab => "banner"
        assert_response :redirect          
        assert_redirected_to :controller => 'projects', 
          :action => "settings", :id => @project, :tab => 'banner'
      end
    end 
  end  
end
