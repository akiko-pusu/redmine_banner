# frozen_string_literal: true

module Banners
  module Api
    class GlobalBannerController < ApplicationController
      # TODO: This group should be customize.
      GLOBAL_BANNER_ADMIN_GROUP = 'GlobalBanner_Admin'

      before_action :require_login, :require_banner_admin
      accept_api_auth :show, :register_banner

      def show
        render json: global_banner_json
      end

      def register_banner
        begin
          global_banner_params = build_params
        rescue ActionController::ParameterMissing, ActionController::UnpermittedParameters => e
          response_bad_request(e.message) && (return)
        end

        retval = Setting.send('plugin_redmine_banner=', global_banner_params.stringify_keys)

        if retval
          render status: 200, json: { status: 'OK', message: 'updating the global banner' }
        else
          response_bad_request("Can't save data to settings table.")
        end
      rescue StandardError => e
        response_internal_server_error(e.message)
      end

      private

      # TODO: Private methods should be refactoring.
      # TODO: Validation is required
      def build_params
        valid_params(params)
      end

      def global_banner_json
        { global_banner: Setting['plugin_redmine_banner'] }
      end

      # 400 Bad Request
      def response_bad_request(error_message = nil)
        json_data = { status: 400, message: 'Bad Request' }
        json_data.merge!(reason: error_message) if error_message.present?
        logger.warn("Global Banner Update failed. Caused: #{json_data}")
        render status: 400, json: json_data
      end

      # 401 Unauthorized
      def response_unauthorized
        render status: 401, json: { status: 401, message: 'Unauthorized' }
      end

      # 500 Internal Server Error
      def response_internal_server_error(error_message = nil)
        json_data = { status: 500, message: 'Internal Server Error' }
        json_data.merge!(reason: error_message) if error_message.present?
        logger.warn("Global Banner Update failed. Caused: #{json_data}")
        render status: 500, json: json_data
      end

      def require_banner_admin
        return if User.current.admin? || banner_admin?(User.current)

        response_unauthorized
      end

      def banner_admin?(user)
        banner_admin_group = Group.find_by_lastname(GLOBAL_BANNER_ADMIN_GROUP)
        return false if banner_admin_group.blank?

        banner_admin_group.users.include?(user)
      end

      def valid_params(params)
        params.require(:global_banner).permit(
          :banner_description,
          :display_part,
          :enable,
          :end_hour, :end_min, :end_ymd,
          :related_link,
          :start_hour, :start_min, :start_ymd,
          :type,
          :use_timer
        )
      end
    end
  end
end
