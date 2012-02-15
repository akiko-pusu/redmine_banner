# Patch for banner plugin. This affects in "plugin" action of Redmine Settings 
# controller.
# Now banner plugin does not have own model(table). So, datetime informations 
# are stored as string and required datetime validation by controller.
# 
# TODO Store banner settings to banner's own model (table).   
#
module SettingsControllerPatch
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
      return plugin_without_banner_date_validation unless params[:id] == "redmine_banner"      
      @plugin = Redmine::Plugin.find(params[:id])

      @partial = @plugin.settings[:partial]
      @settings = Setting["plugin_#{@plugin.id}"]
      
      # date range check
      current_time = Time.now
      @start_datetime = current_time
      @end_datetime = current_time

      if !@settings['start_ymd'].blank?
        s = Date.strptime(@settings['start_ymd'], "%Y-%m-%d")
        s_year = s.year.to_i
        s_month = s.month.to_i
        s_day = s.day.to_i
        s_hour = @settings['start_hour'].blank? ? current_time.hour.to_i : @settings['start_hour'].to_i 
        s_min = @settings['start_min'].blank? ? current_time.min.to_i : @settings['start_min'].to_i 
        @start_datetime = Time.mktime(s_year,s_month, s_day, s_hour, s_min)
      end

      if !@settings['end_ymd'].blank?
        e = Date.strptime(@settings['end_ymd'], "%Y-%m-%d")
        e_year = e.year.to_i
        e_month = e.month.to_i
        e_day = e.day.to_i
        e_hour = @settings['end_hour'].blank? ? current_time.hour.to_i : @settings['end_hour'].to_i 
        e_min = @settings['end_min'].blank? ? current_time.min.to_i : @settings['end_min'].to_i 
        @end_datetime = Time.mktime(e_year,e_month,e_day, e_hour, e_min)
      end        
      
      if request.post?
        return plugin_without_banner_date_validation unless params[:settings][:use_timer] == "true"
        s_string = "#{params[:settings][:start_ymd]} #{params[:settings][:start_hour]}:#{params[:settings][:start_min]}"        
        e_string = "#{params[:settings][:end_ymd]} #{params[:settings][:end_hour]}:#{params[:settings][:end_min]}"

        begin
          s_time = get_time(params[:settings][:start_ymd],
            params[:settings][:start_hour],
            params[:settings][:start_min])
          e_time = get_time(params[:settings][:end_ymd],
            params[:settings][:end_hour],
            params[:settings][:end_min])
          if e_time < s_time
            flash[:error] = l(:error_banner_date_range)
            redirect_to :action => 'plugin', :id => @plugin.id
            return
          end
        rescue => ex
          # Argument Error
          # TODO: Exception will happen about 2038 problem. (Fixed on Ruby1.9)
          flash[:error] = "#{l(:error_banner_date_range)} / #{ex}: From #{s_string} to #{e_string} "
          redirect_to :action => 'plugin', :id => @plugin.id
          return        
        end     
      end
      # Continue to do default action
      plugin_without_banner_date_validation
    end
  end
end
