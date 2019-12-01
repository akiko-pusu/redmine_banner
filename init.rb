require 'redmine'
require 'banners/application_hooks'
require 'banners/settings_controller_patch'
require 'banners/projects_helper_patch'

# NOTE: Keep error message for a while to support Redmine3.x users.
def banner_version_message(original_message = nil)
  <<-"USAGE"
  ==========================
  #{original_message}
  If you use Redmine3.x, please use Redmine Banner version 0.1.x or clone via
  'v0.1.x-support-Redmine3' branch.
  You can download older version from here: https://github.com/akiko-pusu/redmine_banner/releases
  ==========================
  USAGE
end

Redmine::Plugin.register :redmine_banner do
  begin
    name 'Redmine Banner plugin'
    author 'Akiko Takano'
    author_url 'http://twitter.com/akiko_pusu'
    description 'Plugin to show site-wide message, such as maintenacne informations or notifications.'
    version '0.2.2'
    requires_redmine version_or_higher: '4.0'
    url 'https://github.com/akiko-pusu/redmine_banner'

    settings partial: 'settings/redmine_banner', default: {
      enable: 'false',
      banner_description: 'exp. Information about upcoming Service Interruption.',
      type: 'info',
      display_part: 'both',
      use_timer: 'false',
      start_ymd: nil,
      start_hour: nil,
      start_min: nil,
      end_ymd: nil,
      end_hour: nil,
      end_min: nil,
      related_link: nil
    }
    menu :admin_menu, 'icon redmine_banner', { controller: 'settings', action: 'plugin', id: :redmine_banner }, caption: :banner

    project_module :banner do
      permission :manage_banner, { banner: %I[show edit project_banner_off] }, require: :member
    end

    Rails.configuration.to_prepare do
      unless SettingsController.included_modules.include?(Banners::SettingsControllerPatch)
        SettingsController.send(:prepend, Banners::SettingsControllerPatch)
      end
    end
  rescue ::Redmine::PluginRequirementError => e
    raise ::Redmine::PluginRequirementError.new(banner_version_message(e.message)) # rubocop:disable Style/RaiseArgs
  end
end
