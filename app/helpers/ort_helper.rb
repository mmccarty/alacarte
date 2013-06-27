module OrtHelper
  def toc_link_to(name, options = {}, html_options = {})
    html_options.merge!({ :class => 'active' }) if current_page?(options)
    link_to name, options, html_options
  end

  def unit_menu_item(unit, active)
    classes = ''
    if active
      classes += 'active'
    end
    unless unit.resourceables.blank?
      classes += 'dropdown'
    end
    classes
  end

  def unit_menu_link_to(unit)
    if unit.resourceables.blank?
      link_to raw(unit.slug), { :controller => 'ort', :action => 'unit', :id => @tutorial, :uid => unit.id }, :title => unit.title
    else
      link_to raw(unit.slug), { :controller => 'ort', :action => 'unit', :id => @tutorial, :uid => unit.id }, { :title => unit.title, :class => 'dropdown-toggle', :data => { :toggle => 'dropdown' }}
    end
  end

end
