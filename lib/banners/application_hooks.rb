# frozen_string_literal: true

module Banners
  class BannerHeaderHooks < Redmine::Hook::ViewListener
    include ApplicationHelper

    def view_layouts_base_html_head(_context = {})
      o = stylesheet_link_tag('banner', plugin: 'redmine_banner')
      o << javascript_include_tag('banner', plugin: 'redmine_banner')
      o
    end
  end

  #
  # for Project Banner
  #
  class ProjectBannerMessageHooks < Redmine::Hook::ViewListener
    def view_layouts_base_content(context = {})
      project = context[:project]
      return unless enabled?(project)

      banner = Banner.where(project_id: project.id).first
      return '' unless banner&.enable_banner?

      display_part = banner.display_part
      return '' unless action_to_display?(context[:controller], display_part)

      locals_params = { display_part: display_part, banner: banner }
      context[:controller].send(
        :render_to_string, partial: 'banner/project_body_bottom', locals: locals_params
      )
    end

    private

    def enabled?(project)
      return false if project.nil?

      project.module_enabled? :banner
    end

    def action_to_display?(controller, display_part)
      return true if display_part == 'all'

      action_name = controller.action_name
      controller_name = controller.controller_name

      case display_part
      when 'overview'
        return true if controller_name == 'projects' && action_name == 'show'
      when 'overview_and_issues'
        return true if controller_name == 'issues' || (controller_name == 'projects' && action_name == 'show')
      when 'new_issue'
        return true if controller_name == 'issues' && action_name == 'new'
      else
        false
      end
    end
  end

  class BannerMessageHooks < Redmine::Hook::ViewListener
    def pass_timer?(global_banner)
      return true unless global_banner.use_timer?

      Time.zone.now.between?(global_banner.start_time, global_banner.end_time)
    end

    def view_layouts_base_body_bottom(context = {})
      global_banner = GlobalBanner.find_or_default

      # In case global_banner is not stored.
      return if global_banner.updated_on.blank? || global_banner.disable?
      return unless pass_timer?(global_banner)

      setting = global_banner.value
      return unless should_display_on_current_page?(context, setting)

      banner_description = setting['banner_description']
      banner_description.force_encoding('UTF-8') if banner_description.respond_to?(:force_encoding)

      locals_params = { setting: setting.merge(banner_description: banner_description),
                        updated_on: global_banner.updated_on }

      context[:controller].send(
        :render_to_string, partial: 'banner/body_bottom', locals: locals_params
      )
    end

    def should_display_on_current_page?(context, setting)
      return false if ((context[:controller].class.name != 'AccountController') &&
          (context[:controller].action_name != 'login')) &&
                      (setting['display_only_login_page'] == 'true')

      return false if banner_is_off?(context[:controller])
      should_display_for?(setting)
    end

    def should_display_for?(setting)
      target = setting['display_for'] || 'all'
      return true if target == 'all'

      return true if target == 'authenticated' && User.current.logged?
      return true if target == 'anonymous' && User.current.anonymous?

      false
    end

    def banner_is_off?(controller)
      banner_off_time = controller.session[:pref_banner_off]

      global_banner = GlobalBanner.find_or_default

      if !global_banner.blank? && !banner_off_time.blank? && global_banner.updated_on.to_i < banner_off_time
        return true
      end

      false
    end
  end
end
