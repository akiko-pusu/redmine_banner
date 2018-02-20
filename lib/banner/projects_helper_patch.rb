require 'projects_helper'

module Banner
  module ProjectsHelperPatch
    extend ActiveSupport::Concern

    def project_settings_tabs
      tabs = super
      action = { name: 'banner',
                 controller: 'banner',
                 action: :show,
                 partial: 'banner/show', label: :banner }
      tabs << action if User.current.allowed_to?(action, @project)
      tabs
    end
  end
end

ProjectsHelper.prepend Banner::ProjectsHelperPatch
