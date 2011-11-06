class BannerApplicationHooks < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context = {})
    return '' unless Setting.plugin_redmine_banner['enable'] == "true"
    o = ''
    o << stylesheet_link_tag('banner', :plugin => 'redmine_banner')
    o << '<script type="text/javascript">'
    o << 'Event.observe(window, \'load\', window_onload);'
    o << '  function window_onload(evt){'
    o << "    $( \'top-menu\' ).insert({after:\'"
    o << textilize_banner(Setting.plugin_redmine_banner['banner_description'])
    o << '\'});'
    o << '}'
    o << '</script>'

   return o
  end

  def view_layouts_base_body_bottom(context = {})
    return '' unless Setting.plugin_redmine_banner['enable'] == "true"
    o = ''
    o << textilize_banner(Setting.plugin_redmine_banner['banner_description'])
    return o 
  end

  private
  def escape_single_quote(data)
    return data.gsub("'","&rsquo;")
  end

  def textilize_banner(data)
    o = ''
    o << '<div class="banner banner_'
    o << Setting.plugin_redmine_banner['type']
    o << '">'
    o << escape_single_quote(textilizable(data))
    o << '</div>'
    return o 
  end

end

