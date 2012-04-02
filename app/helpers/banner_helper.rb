module BannerHelper  
  def get_time(ymd, h, m)
    d = Date.strptime(ymd, "%Y-%m-%d")
    return Time.mktime(d.year, d.month, d.day, h.to_i, m.to_i)
  end


  def is_action_to_display?(controller, action, project_id)
    begin
      project = Project.find(project_id)
      banner = Banner.find(:first, :conditions => ['project_id = ?', project.id])
      display_part = banner.display_part
    rescue
      return false
    end
      
    return true if display_part == "all"
    if display_part == "overview" and action == "show" and contloller == "ProjectsController"
      return true
    end
    
    if display_part == "overview_and_issues"
      if (action == "show" and contloller == "ProjectsController") || 
          (contloller == "IssuesController")
        return true
      end
    end   
    return false
  end  
end
