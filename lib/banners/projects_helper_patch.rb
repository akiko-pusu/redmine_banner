require 'projects_helper'

module Banners
  module ProjectsHelperPatch
    extend ActiveSupport::Concern

    def project_settings_tabs
      tabs = super
      return tabs unless @project.module_enabled?(:banner)

      tabs.tap { |t| t << append_banner_tab }.compact
    end

    def append_banner_tab
      @banner = Banner.find_or_create(@project.id)
      action = { name: 'banner',
                 controller: 'banner',
                 action: :show,
                 partial: 'banner/show', label: :banner }
      return nil unless User.current.allowed_to?(action, @project)

      action
    end
  end
end

ProjectsController.helper(Banners::ProjectsHelperPatch)
