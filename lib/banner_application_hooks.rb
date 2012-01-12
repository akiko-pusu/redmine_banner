class BannerApplicationHooks < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context = {})
    return '' unless Setting.plugin_redmine_banner['enable'] == "true"
    o = stylesheet_link_tag('banner', :plugin => 'redmine_banner')
    return o
  end

  # TODO: view_layouts_base_after_top_menu is not supported Redmine itself. (Submitted ticket: http://www.redmine.org/issues/9915)
  render_on :view_layouts_base_body_bottom, :partial => 'banner/body_bottom'
  render_on :view_layouts_base_after_top_menu, :partial => 'banner/after_top_menu'
  
end

