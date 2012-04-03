module BannerHelper  
  def get_time(ymd, h, m)
    d = Date.strptime(ymd, "%Y-%m-%d")
    return Time.mktime(d.year, d.month, d.day, h.to_i, m.to_i)
  end


  def is_action_to_display?(controller, display_part)
    action_name = controller.action_name
    controller_name = controller.controller_name
    case display_part
    when "overview" then
      return false unless controller_name == 'projects' && action_name == 'show' 
    when "overview_and_issues" then
      if controller_name != 'issues' && !(controller_name == 'projects' && action_name == 'show' )
        return false
      end
    when "all" then
      return true
    else
      return false  
    end
  end
end