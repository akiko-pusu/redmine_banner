# frozen_string_literal: true

class GlobalBanner < Setting
  # Default
  GLOBAL_BANNER_ADMIN_GROUP = 'GlobalBanner_Admin'

  GLOBAL_BANNER_DEFAULT_SETTING = {
    enable: 'false',
    banner_description: 'exp. Information about upcoming Service Interruption.',
    only_authenticated: nil,
    display_only_login_page: nil,
    type: 'info',
    display_part: 'both',
    use_timer: 'false',
    start_ymd: nil,
    start_hour: nil,
    start_min: nil,
    end_ymd: nil,
    end_hour: nil,
    end_min: nil,
    related_link: nil,
    banner_admin: nil
  }.freeze

  # Class method
  #
  class << self
    def find_or_default
      super('plugin_redmine_banner')
    end

    def banner_admin?(user)
      return true if user.admin?

      instance = find_or_default
      instance.banner_admin?(user)
    end
  end

  def admin_group
    value[:admin_group] || GLOBAL_BANNER_ADMIN_GROUP
  end

  def banner_admin?(user)
    return true if user.admin?

    admin_group = value['banner_admin'] || GLOBAL_BANNER_ADMIN_GROUP

    banner_admin_group = Group.find_by(lastname: admin_group)
    return false if banner_admin_group.blank?

    banner_admin_group.users.include?(user)
  end

  def use_timer?
    value['use_timer'] == 'true'
  end

  def start_time
    get_time(
      value['start_ymd'],
      value['start_hour'],
      value['start_min']
    )
  end

  def end_time
    get_time(
      value['end_ymd'],
      value['end_hour'],
      value['end_min']
    )
  end

  def get_time(ymd, hour, minute)
    begin
      d = Date.strptime(ymd, '%Y-%m-%d')
    rescue StandardError => e
      logger&.warn("Passed value #{ymd} for Banner has wrong format. #{e.message}")
      d = Date.current
    end
    Time.mktime(d.year, d.month, d.day, hour.to_i, minute.to_i)
  end

  def valid_date_range?
    return true unless use_timer?

    end_time > start_time
  end

  def enable?
    value['enable'] == 'true'
  end

  def disable?
    value['enable'] != 'true'
  end

  def merge_value(new_value)
    current_value = value
    self.value = current_value.merge(new_value).stringify_keys
  end
end
