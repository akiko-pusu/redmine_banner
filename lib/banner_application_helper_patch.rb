module BannerApplicationHelperPatch
  def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def is_action_to_display?(controller, display_part)
      action_name = controller.action_name
      controller_name = controller.controller_name
      case display_part
      when "overview" then
        return true if controller_name == 'projects' && action_name == 'show' 
      when "overview_and_issues" then
        if controller_name == 'issues' || (controller_name == 'projects' && action_name == 'show' )
          return true
        end
      when "new_issue" then
        if controller_name == 'issues' && action_name == 'new'
          return true
        end        
      when "all" then
        return true
      else
        return false  
      end
    end
  end    
end

# Add module to Issue
ApplicationHelper.send(:include, BannerApplicationHelperPatch)
