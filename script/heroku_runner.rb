# frozen_string_literal: true

api_key = ENV['BANNER_API_KEY']
pass = ENV['BANNER_VER']

puts api_key

admin = User.find_by_login('admin')
admin.update!(password: pass, must_change_passwd: false)
version = ENV['BANNER_VER']

Setting.rest_api_enabled = '1'

if admin.api_token.nil?
  admin.send(:api_key)
end

token = Token.where(action: 'api').where(user_id: admin.id).first
token.update_attributes(value: api_key) unless token.blank?

description = 'This is a test message for Global Banner. '
description += "(#{version} / Redmine trunk: #{Redmine::VERSION::REVISION || Redmine::VERSION})"

puts version
puts description

Setting.send('plugin_redmine_banner=',
             { enable: 'true', type: 'info', display_part: 'both',
               banner_description: description }.stringify_keys)
