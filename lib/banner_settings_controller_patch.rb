# Patch for banner plugin. This affects in "plugin" action of Redmine Settings
# controller.
# Now banner plugin does not have own model(table). So, datetime informations
# are stored as string and required datetime validation by controller.
#
# TODO Store banner settings to banner's own model (table).
#
module BannerSettingsControllerPatch
  unloadable
  include BannerHelper

  def self.included(base)
    base.send(:include, ClassMethods)
    base.class_eval do
      alias_method_chain(:plugin, :banner_date_validation)
    end
  end

  module ClassMethods
    #
    # Before posting start / end date, do validation check.(In case setting "Use timer".)
    #
    def plugin_with_banner_date_validation
      param_id = params[:id]
      return plugin_without_banner_date_validation if param_id != 'redmine_banner'
      plugin = Redmine::Plugin.find(param_id)
      settings = Setting["plugin_#{plugin.id}"]

      @banner_updated_on = nil
      if Setting.find_by_name('plugin_redmine_banner').present?
        @banner_updated_on = Setting.find_by_name('plugin_redmine_banner').updated_on.localtime
      end

      # date range check
      current_time = Time.now
      begin
        # date range check
        @start_datetime = generate_time(settings, 'start', current_time)
        @end_datetime   = generate_time(settings, 'end', current_time)
      rescue => ex
        # Ref. https://github.com/akiko-pusu/redmine_banner/issues/11
        # Logging when Argument Error
        if logger
          logger.warn "Redmine Banner Warning:  #{ex} / Invalid date setting / From #{settings['start_ymd']} to #{settings['end_ymd']}. Reset to current datetime. "
        end
        @start_datetime = current_time
        @end_datetime = current_time
        settings['use_timer'] = 'false'
      end

      if request.post?
        param_settings = params[:settings]
        return plugin_without_banner_date_validation if param_settings[:use_timer] != 'true'
        begin
          unless validate_date_range?(param_settings)
            flash[:error] = l(:error_banner_date_range)
            redirect_to action: 'plugin', id: plugin.id
            return
          end

        rescue => ex
          # Argument Error
          # TODO: Exception will happen about 2038 problem. (Fixed on Ruby1.9)
          s_string = "#{param_settings[:start_ymd]} #{param_settings[:start_hour]}:#{param_settings[:start_min]}"
          e_string = "#{param_settings[:end_ymd]} #{param_settings[:end_hour]}:#{param_settings[:end_min]}"

          flash[:error] = "#{l(:error_banner_date_range)} / #{ex}: From #{s_string} to #{e_string} "
          redirect_to action: 'plugin', id: plugin.id
          return
        end
      end

      # Continue to do default action
      plugin_without_banner_date_validation
    end

    private

    def generate_time(settings, type, current_time)
      return current_time if settings["#{type}_ymd"].blank?

      # generate time
      d = Date.strptime(settings["#{type}_ymd"], '%Y-%m-%d')
      d_year = d.year.to_i
      d_month = d.month.to_i
      d_day = d.day.to_i
      d_hour = settings["#{type}_hour"].blank? ? current_time.hour.to_i : settings["#{type}_hour"].to_i
      d_min = settings["#{type}_min"].blank? ? current_time.min.to_i : settings["#{type}_min"].to_i
      Time.mktime(d_year, d_month, d_day, d_hour, d_min)
    end

    def validate_date_range?(param_settings)
      s_time = get_time(param_settings[:start_ymd], param_settings[:start_hour], param_settings[:start_min])
      e_time = get_time(param_settings[:end_ymd], param_settings[:end_hour], param_settings[:end_min])
      e_time > s_time
    end
  end
end
