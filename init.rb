# frozen_string_literal: true

require 'redmine'
require_relative 'app/models/global_banner'
require 'banners/application_hooks'
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

def banner_admin?
  GlobalBanner.banner_admin?(User.current)
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

    settings partial: nil, default: GlobalBanner::GLOBAL_BANNER_DEFAULT_SETTING

    menu :admin_menu, 'icon redmine_banner', { controller: 'global_banner', action: 'show', "id": nil }, caption: :banner
    menu :top_menu, :redmine_banner, { controller: 'global_banner', action: 'show', "id": nil }, caption: :banner,
                                                                                                 last: true,
                                                                                                 if: proc { banner_admin? }

    project_module :banner do
      permission :manage_banner, { banner: %I[show edit project_banner_off] }, require: :member
    end
  rescue ::Redmine::PluginRequirementError => e
    raise ::Redmine::PluginRequirementError.new(banner_version_message(e.message)) # rubocop:disable Style/RaiseArgs
  end
end
