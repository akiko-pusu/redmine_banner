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
        begin
          global_banner_params = build_params
        rescue ActionController::ParameterMissing, ActionController::UnpermittedParameters => e
          response_bad_request(e.message) && (return)
        end

        global_banner = GlobalBanner.find_or_default
        global_banner.merge_value(global_banner_params.stringify_keys)

        if global_banner.save
          render status: :ok, json: { status: 'OK', message: 'updating the global banner' }
        else
          response_bad_request("Can't save data to settings table.")
        end
      rescue StandardError => e
        response_internal_server_error(e.message)
      end

      private

      def build_params
        keys = GlobalBanner::GLOBAL_BANNER_DEFAULT_SETTING.stringify_keys.keys

        unless User.current.admin?
          keys.delete('banner_admin')
        end

        params.require(:global_banner).permit(keys)
      end

      def global_banner_json
        { global_banner: GlobalBanner.find_or_default.value }
      end

      # 400 Bad Request
      def response_bad_request(error_message = nil)
        json_data = { status: 400, message: 'Bad Request' }
        json_data[:reason] = error_message if error_message.present?
        logger&.warn("Global Banner Update failed. Caused: #{json_data}")

        render status: :bad_request, json: json_data
      end

      # 401 Unauthorized
      def response_unauthorized
        render status: :unauthorized, json: { status: 401, message: 'Unauthorized' }
      end

      # 500 Internal Server Error
      def response_internal_server_error(error_message = nil)
        json_data = { status: 500, message: 'Internal Server Error' }
        json_data[:reason] = error_message if error_message.present?
        logger&.warn("Global Banner Update failed. Caused: #{json_data}")

        render status: :internal_server_error, json: json_data
      end

      def require_banner_admin
        return if User.current.admin? || banner_admin?(User.current)

        response_unauthorized
      end

      def banner_admin?(user)
        GlobalBanner.banner_admin?(user)
      end
    end
  end
end
