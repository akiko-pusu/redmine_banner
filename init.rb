require 'redmine'
require 'banner_application_hooks'

Redmine::Plugin.register :redmine_banner do
  name 'Redmine Banner plugin'
  author 'Akiko Takano'
  description 'Plugin to show site-wide message, such as maintenacne informations or notifications.'
  version '0.0.1'
  requires_redmine :version_or_higher => '1.2.0'
  url 'https://github.com/akiko-pusu/redmine_banner'

  settings :partial => 'settings/redmine_banner',
    :default => {
      'enable' => 'false',
      'banner_description' => 'exp. Information about upcoming Service Interruption.',
      'type' => 'info'
    }

end
