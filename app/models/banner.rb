# frozen_string_literal: true

class Banner < ActiveRecord::Base
  include Redmine::SafeAttributes
  belongs_to :project

  validates :project_id, uniqueness: true
  validates :project_id, presence: true
  validates :display_part, inclusion: { in: %w[all new_issue overview overview_and_issues] }
  validates :style, inclusion: { in: %w[info warn alert normal nodata] }
  # project should be stable.
  safe_attributes 'banner_description', 'style', 'start_date', 'end_date', 'enabled', 'use_timer', 'display_part'

  def self.find_or_create(project_id)
    banner = Banner.find_by(project_id: project_id)
    if banner.blank?
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
    return true if enabled == true && banner_description.present?

    false
  end
end
