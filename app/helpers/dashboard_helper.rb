module DashboardHelper
  def activity_link(object)
    case object.class.name
    when 'Page'
      link_to truncate(h(object.header_title),:length => 20), {:controller => 'page', :action => 'edit',  :id => object.id}, :title => "edit page"
    when 'Guide'
      link_to truncate(h(object.guide_name),:length => 20), {:controller => 'guide', :action => 'edit',  :id => object.id}, :title => "edit guide"
    else
      link_to truncate(h(object.label),:length => 20), {:controller => 'nodes', :action => 'edit_content',  :id => object.id}, :title => "edit module"
    end
  end
end
