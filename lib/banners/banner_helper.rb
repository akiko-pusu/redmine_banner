# frozen_string_literal: true

module Banners
  module BannerHelper
    def get_time(ymd, hour, minute)
      begin
        d = Date.strptime(ymd, '%Y-%m-%d')
      rescue StandardError => e
        logger.warn("Passed value #{ymd} for Banner has wrong format. #{e.message}")
        d = Date.current
      end
      Time.mktime(d.year, d.month, d.day, hour.to_i, minute.to_i)
    end

    def enabled?(project)
      return false if project.nil?

      project.module_enabled? :banner
    end

    def action_to_display?(controller, display_part)
      return true if display_part == 'all'

      action_name = controller.action_name
      controller_name = controller.controller_name

      case display_part
      when 'overview' then
        return true if controller_name == 'projects' && action_name == 'show'
      when 'overview_and_issues' then
        return true if controller_name == 'issues' || (controller_name == 'projects' && action_name == 'show')
      when 'new_issue' then
        return true if controller_name == 'issues' && action_name == 'new'
      else
        return false
      end
    end

    module_function :enabled?, :action_to_display?
  end
end
