# frozen_string_literal: true

class GlobalBannerController < ApplicationController
  before_action :require_login, :require_banner_admin

  def show
    global_banner = GlobalBanner.find_or_default
    render layout: !request.xhr?, locals: setting_values(global_banner)
  end

  def update
    global_banner = GlobalBanner.find_or_default

    begin
      global_banner_params = build_params
    rescue ActionController::ParameterMissing, ActionController::UnpermittedParameters => e
      response_bad_request(e.message) && (return)
    end

    global_banner.merge_value(global_banner_params.stringify_keys)

    unless global_banner.valid_date_range? && global_banner.save
      flash[:error] = l(:error_banner_date_range)
      redirect_to action: 'show'
      return
    end

    flash[:notice] = l(:notice_successful_update)
    redirect_to action: 'show'
    nil
  end

  private

  def require_banner_admin
    return if User.current.admin? || GlobalBanner.banner_admin?(User.current)

    render_403
    false
  end

  def build_params
    keys = GlobalBanner::GLOBAL_BANNER_DEFAULT_SETTING.stringify_keys.keys

    unless User.current.admin?
      keys.delete('banner_admin')
    end

    params.require(:setting).permit(keys)
  end

  def setting_values(instance)
    setting = instance.value

    current_time = Time.zone.now
    use_timer = instance.use_timer?

    begin
      # date range check
      start_datetime = instance.start_time
      end_datetime = instance.end_time
    rescue ArgumentError
      # Ref. https://github.com/akiko-pusu/redmine_banner/issues/11
      start_datetime = current_time
      end_datetime = current_time
      use_timer = false
    end

    banner_description = setting[:banner_description]

    if banner_description.respond_to?(:force_encoding)
      setting[:banner_description] = banner_description.force_encoding('UTF-8')
    end

    {
      setting: setting.stringify_keys,
      start_datetime: start_datetime,
      end_datetime: end_datetime,
      use_timer: use_timer,
      banner_updated_on: instance&.updated_on&.localtime
    }
  end
end
