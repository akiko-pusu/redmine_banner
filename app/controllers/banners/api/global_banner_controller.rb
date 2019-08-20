# frozen_string_literal: true

module Banners
  module Api
    class GlobalBannerController < ApplicationController
      before_action :require_login, :require_banner_admin
      accept_api_auth :show, :register_banner

      def show
        render json: global_banner_json
      end

      def register_banner
        global_banner_params = build_params

        retval = Setting.send('plugin_redmine_banner=', global_banner_params.stringify_keys)

        if retval
          render status: 200, json: { status: 'OK', message: 'updatig the global banner' }
        else
          render status: 400, json: { status: 400, message: 'Bad Request' }
        end
      rescue StandardError => e
        logger.warn("Global Banner Update failed. Caused: #{e.message}")
        response_internal_server_error
      end

      # TODO: Validation is required
      def build_params
        JSON.parse(request.body.read)
      end

      def global_banner_json
        Setting['plugin_redmine_banner'].to_json
      end

      # 400 Bad Request
      def response_bad_request
        render status: 400, json: { status: 400, message: 'Bad Request' }
      end

      # 401 Unauthorized
      def response_unauthorized
        render status: 401, json: { status: 401, message: 'Unauthorized' }
      end

      # 500 Internal Server Error
      def response_internal_server_error
        render status: 500, json: { status: 500, message: 'Internal Server Error' }
      end

      def require_banner_admin
        return if User.current.admin? || banner_admin?(User.current)

        response_unauthorized
      end

      def banner_admin?(user)
        banner_admin_group = Group.find_by_lastname('GlobalBanner_Admin')
        banner_admin_group.users.include?(user)
      end
    end
  end
end
