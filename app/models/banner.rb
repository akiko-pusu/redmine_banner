class Banner < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable
  belongs_to :project

  validates_uniqueness_of :project_id
  validates_presence_of :project_id
  # project should be stable.
  safe_attributes 'banner_description', 'style', 'start_date', 'end_date', 'enabled', 'use_timer', 'display_part'
  
  def self.find_or_create(project_id)	
    banner = Banner.find(:first, :conditions => ['project_id = ?', project_id])
    unless banner
      banner = Banner.new
      banner.project_id = project_id
      banner.enabled = false
      banner.save!      
    end
    return banner
  end
  
  def enable_banner?
    if self.enabled == true && !self.banner_description.blank?
      return true
    end
    return false
  end

end
