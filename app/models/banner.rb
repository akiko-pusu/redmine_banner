class Banner < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable
  belongs_to :project

  validates_uniqueness_of :project_id
  validates :project_id, presence: true
  validates_inclusion_of :display_part, in: %w(all new_issue overview overview_and_issues)
  validates_inclusion_of :style, in: %w(info warn alert normal nodata)
  # project should be stable.
  safe_attributes 'banner_description', 'style', 'start_date', 'end_date', 'enabled', 'use_timer', 'display_part'
  attr_accessible :enabled, :style, :display_part, :banner_description

  def self.find_or_create(project_id)
    banner = Banner.where(['project_id = ?', project_id]).first
    unless banner.present?
      banner = Banner.new
      banner.project_id = project_id
      banner.enabled = false

      # Set default (Also set default by migration file)
      banner.display_part = 'all'
      banner.style = 'info'
      banner.save!
    end
    banner
  end

  def enable_banner?
    return true if enabled == true && !banner_description.blank?
    false
  end
end
