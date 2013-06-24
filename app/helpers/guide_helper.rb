module GuideHelper
  def guide_search_params(search, guide)
    guide_params = {
      'publish' => { :action => 'publish', :controller => 'guide', :id => guide, :page => @page, :sort => @sort }
    }
    guide_params['publish'][:search] = search if search
    guide_params
  end
end
