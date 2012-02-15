require 'redmine'
require 'banner_application_hooks'
require 'dispatcher'
require 'settings_controller_patch'

Redmine::Plugin.register :redmine_banner do
  name 'Redmine Banner plugin'
  author 'Akiko Takano'
  description 'Plugin to show site-wide message, such as maintenacne informations or notifications.'
  version '0.0.3'
  requires_redmine :version_or_higher => '1.2.0'
  url 'https://github.com/akiko-pusu/redmine_banner'

  settings :partial => 'settings/redmine_banner',
    :default => {
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
      'end_min' => nil
    }
  menu :admin_menu, :redmine_banner, { :controller => 'settings', :action => 'plugin', :id => :redmine_banner }, :caption => :banner

  
Dispatcher.to_prepare do
  #include our code
  SettingsController.send(:include, SettingsControllerPatch)
end  
end
