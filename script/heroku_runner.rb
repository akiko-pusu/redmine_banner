# frozen_string_literal: true

api_key = ENV['BANNER_API_KEY']
pass = ENV['BANNER_VER']

admin = User.find_by_login('admin')
admin.update!(password: pass, must_change_passwd: false)
version = ENV['BANNER_VER']

Setting.rest_api_enabled = '1'

# set banner test user
banner_user = User.find_by_login('banner_test')
if banner_user.blank?
  banner_user = User.new(firstname: 'banner', lastname: 'test', login: 'banner_test', status: 1)
  banner_user.mail = 'banner_test@example.com'
  banner_user.save
end

# find or create for GlobalBanner Admin group
banner_group = Group.find_by_lastname('GlobalBanner_Admin')
if banner_group.blank?
  banner_group = Group.create(name: 'GlobalBanner_Admin')
end
banner_group.user_ids = [banner_user.id]
banner_group.save

# Update user's api
if banner_user.api_token.nil?
  banner_user.send(:api_key)
end

token = Token.where(action: 'api').where(user_id: banner_user.id).first
token.update_attributes(value: api_key) unless token.blank?
banner_user.api_token = token
banner_user.save

# Load message file
ja_kodomo_file = "#{Rails.root}/public/themes/redmine_theme_kodomo/i18n/message_ja.yml"
custom_message_setting = CustomMessageSetting.find_or_default
custom_message_setting.update_with_custom_messages_yaml(File.read(ja_kodomo_file))

description = 'This is a test message for Global Banner. '
description += "(#{version} / Redmine trunk: #{Redmine::VERSION::REVISION || Redmine::VERSION})"

# Add banner message
message = {
  enable: 'true',
  type: 'info',
  display_part: 'both',
  banner_description: description
}

banner_setting = Setting.find_or_default('plugin_redmine_banner')
banner_setting.value = message.stringify_keys
banner_setting.save

# Apply theme
Setting.ui_theme = 'redmine_theme_kodomo'
Setting.app_title = 'こどもれっどまいん'
