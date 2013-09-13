class TabsController < ApplicationController
  include Paginating
  before_filter :find_parent
  layout 'admin'

  def new
    if @parent.reached_limit?
      flash[:error] = "Could not create the tab. This guide has reached the 6 tab limit"
      redirect_to @parent
    else
      tab = Tab.new tab_name: 'New Tab'
      tab.position = @parent.tabs.length + 1
      @parent.tabs << tab
      session[:current_tab] = tab.id
      redirect_to @parent
    end
  end

  def show
    @tab = find_tab
    if @tab and request.xhr?
      if @tab.num_columns == 1
        @mods = @tab.tab_nodes
      else
        @mods_left  = @tab.left_nodes
        @mods_right = @tab.right_nodes
      end
      polymorphic_partial @parent, 'edit_tab'
    else
      redirect_to @parent
    end
  end

  def save_tab_name
    tab = Tab.find(params[:id])
    tab.tab_name = params[:value]
    tab.save
    render :json => params[:value]
  end

  def delete
    tabs = @parent.tabs
    unless tabs.length == 1
      tab  = tabs.select{ |t| t.id == params[:id].to_i}.first
      tabs.destroy(tab)
      session[:current_tab] = nil
    else
      flash[:error] = "Can not delete the tab. A guide must have at least one tab."
    end
    redirect_to @parent
  end

  def sort
    if params['left'] then
      sortables = params['left']
      sortables.each do |id|
        tab_node = @tab.tab_nodes.find(id)
        tab_node.update_attribute(:position, 2*sortables.index(id) + 1 )
      end
    elsif params['right'] then
      sortables = params['right']
      sortables.each do |id|
        tab_node = @tab.tab_nodes.find(id)
        tab_node.update_attribute(:position, 2*sortables.index(id) + 2 )
      end
    elsif params['full'] then
      sortables = params['full']
      sortables.each do |id|
        tab_node = @tab.tab_nodes.find(id)
        tab_node.update_attribute(:position, sortables.index(id) + 1 )
      end
    end
    render nothing: true
  end

  def add_mod
    session[:add_mods] ||= []
    s = params[:mid1] + params[:mid2]
    unless session[:add_mods].include?(s)
      session[:add_mods] << s
    end
    render nothing: true
  end

  def add_nodes
    @tab = find_tab
    @sort = params[:sort] || 'label'
    session[:add_mods] ||= []
    @mods = @user.sort_mods(@sort)
    @mods = paginate_nodes(@mods, params[:page] ||= 1, @sort)
    if request.post? and !session[:add_mods].nil?
      @tab.update_nodes(session[:add_mods])
      @parent.update_users if @parent and @parent.shared?
      session[:add_mods] = nil
      redirect_to [@parent, @tab]
    end
  end

  def new_node
    @mod = create_node_object
    @mod.attributes = params[:mod]
    if @mod.save
      create_and_add_node(@user,@mod,@tab)
      redirect_to  :controller => 'node',:action => 'edit_content' , :id =>@mod.id
    else
      flash[:error] = "Could not create the node. There were problems with the following fields: #{@mod.errors.full_messages.join(", ")}"
      flash[:mod_title] = params[:mod][:module_title]
      flash[:mod_title_error] = @mod.errors[:module_title]
      redirect_to  :back
    end
  end

  def remove_node
    find_tab.tab_nodes.where(node_id: params[:mod]).first.delete
    redirect_to :back
  end

  def toggle_columns
    find_tab.toggle_columns
    redirect_to @parent
  end

  def reorder_nodes
    if params[:resource_ids]
      resource_ids = params[:resource_ids]
    else
      resource_ids = []
      left_ids = params[:left_ids] || []
      right_ids = params[:right_ids] || []
      max_len = [left_ids, right_ids].map(&:length).max
      max_len.times do |i|
        resource_ids << left_ids[i]  if i < left_ids.length
        resource_ids << right_ids[i] if i < right_ids.length
      end
    end
    find_tab.reorder_nodes resource_ids.map(&:to_i)
    render nothing: true
  end

  private

  def find_parent
    @guide = Guide.find params[:guide_id] if params[:guide_id]
    @page = Page.find params[:page_id] if params[:page_id]
    @parent = @guide || @page
  end

  def find_tab
    @tab = @parent.tabs.find params[:id]
    session[:current_tab] = @tab.id
    @tab
  end
end
