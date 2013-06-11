module TaggedHelper
  def render_tag_list(tag, css)
    options = {
      :update => 'table',
      :loading => "Element.show('spinner_sort')",
      :complete => "Element.hide('spinner_sort')",
      :class => css,
      :url => {:action => 'index',:params => params.merge({:tag => tag})}
    }
    html_options = {
      :title => "Sort by this tag",
      :class => css,
      :href => url_for(:action => 'index', :params => params.merge({:tag => tag}))
    }
    link_to(tag, options, html_options, :remote => true)
  end
end
