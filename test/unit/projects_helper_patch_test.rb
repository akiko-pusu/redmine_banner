require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../lib/banners/projects_helper_patch')
require 'minitest/autorun'

class ProjectsHelperPatchTest < Redmine::HelperTest
  include ApplicationHelper
  include ProjectsHelper

  fixtures :projects, :users

  def setup
    MockHelperInstance.prepend(Banners::ProjectsHelperPatch)
    User.current = User.first
    @project = Project.first
    @mock_helper_instance = MockHelperInstance.new(@project)
  end

  def test_patch_applied
    assert_equal true, @mock_helper_instance.respond_to?(:project_settings_tabs)
    assert_equal true, @mock_helper_instance.respond_to?(:append_banner_tab)
  end

  def test_project_settings_tabs
    tabs = @mock_helper_instance.project_settings_tabs
    tab_names = tabs.map { |h| h[:name] }
    assert_equal true, tabs.any?
    assert_equal false, tab_names.include?('banner')
  end

  def test_project_settings_tabs_with_banner_enabled
    EnabledModule.create(name: 'banner', project_id: @project.id)
    tabs = @mock_helper_instance.project_settings_tabs
    tab_names = tabs.map { |h| h[:name] }
    assert_equal true, tabs.any?
    assert_equal true, tab_names.include?('banner')
  end

  def test_append_banner_tab_called
    mock = Minitest::Mock.new.expect(:call, true)
    EnabledModule.create(name: 'banner', project_id: @project.id)
    @mock_helper_instance.stub :append_banner_tab, mock do
      @mock_helper_instance.project_settings_tabs
    end
    mock.verify
  end
end

class MockHelperInstance
  include ProjectsHelper
  attr_reader :project
  def initialize(project)
    @project = project
  end

  # mock parameter
  def params
    { version_status: 'active', version_name: 'latest' }
  end
end
