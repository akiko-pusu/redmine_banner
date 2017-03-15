module BannerHelper
  def get_time(ymd, h, m)
    d = Date.strptime(ymd, '%Y-%m-%d')
    Time.mktime(d.year, d.month, d.day, h.to_i, m.to_i)
  end

  def enabled?(project)
    return false if project.nil?
    project.module_enabled? :banner
  end

  def action_to_display?(controller, display_part)
    action_name = controller.action_name
    controller_name = controller.controller_name
    return true if display_part == 'all'

    case display_part
    when 'overview' then
      return true if controller_name == 'projects' && action_name == 'show'
    when 'overview_and_issues' then
      if controller_name == 'issues' || (controller_name == 'projects' && action_name == 'show')
        return true
      end
    when 'new_issue' then
      return true if controller_name == 'issues' && action_name == 'new'
    else
      return false
    end
  end

  module_function :enabled?
  module_function :action_to_display?
end
