module PageHelper
  def page_search_params(search,id,page)
    page_params = {}
    if search #if request came from a search, add search term to paramaters
      page_params['publish'] = {:action => 'publish',:controller => 'page', :id => id, :page => page, :sort => @sort, :search => search}
      page_params['archive'] = {:action => 'archive', :controller => 'page', :id => id, :page => page, :sort => @sort, :search => search}
      page_params['destroy'] = {:action => 'destroy', :controller => 'page',:id => id, :page => @pag, :sort => @sort, :search => search}
    else
      page_params['publish'] = {:action => 'publish',:controller => 'page', :id => id, :page => page, :sort => @sort}
      page_params['archive'] = {:action => 'archive', :controller => 'page', :id => id, :page => page, :sort => @sort}
      page_params['destroy'] = {:action => 'destroy', :controller => 'page',:id => id, :page => @pag, :sort => @sort}
    end
    return page_params
  end
end
