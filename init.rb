require 'redmine'
require 'banner_application_hooks'
require 'banner_settings_controller_patch'
require 'banner_projects_helper_patch'

Redmine::Plugin.register :redmine_banner do
  name 'Redmine Banner plugin'
  author 'Akiko Takano'
  author_url 'http://twitter.com/akiko_pusu'
  description 'Plugin to show site-wide message, such as maintenacne informations or notifications.'
  version '0.1.2'
  requires_redmine version_or_higher: '2.5.0'
  url 'https://github.com/akiko-pusu/redmine_banner'

  settings partial: 'settings/redmine_banner',
           default: {
             'enable' => 'false',
             'banner_description' => 'exp. Information about upcoming Service Interruption.',
             'type' => 'info',
             'display_part' => 'both',
             'use_timer' => 'false',
             'start_ymd' => nil,
             'start_hour' => nil,
             'start_min' => nil,
             'end_ymd' => nil,
             'end_hour' => nil,
             'end_min' => nil,
             'related_link' => nil
           }
  menu :admin_menu, 'icon redmine_banner', { controller: 'settings',
                                       action: 'plugin', id: :redmine_banner }, caption: :banner

  project_module :banner do
    permission :manage_banner,
               { banner: [:show, :edit, :project_banner_off] }, require: :member
  end

  Rails.configuration.to_prepare do
    require_dependency 'projects_helper'
    unless SettingsController.included_modules.include?(BannerSettingsControllerPatch)
      SettingsController.send(:include, BannerSettingsControllerPatch)
    end
    unless ProjectsHelper.included_modules.include? BannerProjectsHelperPatch
      ProjectsHelper.send(:include, BannerProjectsHelperPatch)
    end
  end
end
