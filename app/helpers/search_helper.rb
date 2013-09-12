module SearchHelper
  def search_results_message
    #If there were no matching results, just show 0 results instead of listing the record numbers being shown on the page
    return "#{pluralize(@search_results.total_entries,"result")}"
  end

  def setTitleAction
    if session[:guide_id]
      render :partial => '/guide/title_actions'
    elsif session[:page_id]
      render :partial => '/page/title_actions'
    end
  end

  def setEditLink
    if session[:guide_id]
      link_to 'Choose a different tab.', {:controller => 'guide', :action => 'edit',  :id => @guide.id}
    elsif session[:page_id]
      link_to 'Choose a different tab.', {:controller => 'page', :action => 'edit',  :id => @page.id}
    end
  end

  def setSideBar
    if session[:guide_id]
      render :partial => 'guide/side_bar'
    elsif session[:page_id]
      render :partial => 'page/side_bar'
    end
  end

  def set_controller
    if session[:guide_id]
      return "tab"
    elsif session[:page_id]
      return "tab"
    end
  end

  def set_action
    if session[:guide_id]
      return "add_modules"
    elsif session[:page_id]
      return "page_add_modules"
    end
  end

  def set_id
    if session[:guide_id]
      return @tab.id
    elsif session[:page_id]
      return @tab.id
    end
  end

  def set_return_to_tab_button
    if session[:guide_id]
      link_to 'All Modules', {:controller => 'tab', :action => 'add_modules'},  :id => @guide.id,:sort => 'name',:method => 'put'
    elsif session[:page_id]
      link_to 'All Modules', {:controller => 'tab', :action => 'page_add_modules'},  :id => @page.id,:sort => 'name',:method => 'put'
    end
  end

  def set_tab_unit_message
    "On Tab: #{@tab.tab_name}"
  end

  def set_tab_or_unit
    "tab"
  end
end
