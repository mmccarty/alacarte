class TabsController < ApplicationController
  include Paginating
  before_filter :module_types, :only =>[ :add_modules, :page_add_modules]
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
        @mods = @tab.tab_resources
      else
        @mods_left  = @tab.left_resources
        @mods_right = @tab.right_resources
      end
      polymorphic_partial @parent, 'edit_tab'
    else
      redirect_to @parent
    end
  end

  def sort_tabs
    if params['drag'] then
      sortables = params['drag']
      sortables.each do |id|
        tab = Tab.find(id)
        tab.update_attribute(:position, sortables.index(id) + 1 )
      end
    end
    render :nothing => true
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
        tab_resource = @tab.tab_resources.find(id)
        tab_resource.update_attribute(:position, 2*sortables.index(id) + 1 )
      end
    elsif params['right'] then
      sortables = params['right']
      sortables.each do |id|
        tab_resource = @tab.tab_resources.find(id)
        tab_resource.update_attribute(:position, 2*sortables.index(id) + 2 )
      end
    elsif params['full'] then
      sortables = params['full']
      sortables.each do |id|
        tab_resource = @tab.tab_resources.find(id)
        tab_resource.update_attribute(:position, sortables.index(id) + 1 )
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

  def add_modules
    @tab = find_tab
    @sort = params[:sort] || 'label'
    session[:add_mods] ||= []
    @mods = @user.sort_mods(@sort)
    @mods = paginate_mods(@mods, params[:page] ||= 1, @sort)
    if request.post? and !session[:add_mods].nil?
      @tab.update_resource(session[:add_mods])
      @parent.update_users if @parent and @parent.shared?
      session[:add_mods] = nil
      redirect_to [@parent, @tab]
    end
  end

  def new_module
    unless params[:mod][:type].empty?
      @mod = create_module_object(params[:mod][:type])
      @mod.attributes = params[:mod]
      if @mod.save
        create_and_add_resource(@user,@mod,@tab)
        redirect_to  :controller => 'module',:action => 'edit_content' , :id =>@mod.id, :type => @mod.class
      else
        flash[:error] = "Could not create the module. There were problems with the following fields: #{@mod.errors.full_messages.join(", ")}"
        flash[:mod_title] = params[:mod][:module_title]
        flash[:mod_type] = params[:mod][:type]
        flash[:mod_title_error] = @mod.errors[:module_title]
        flash[:mod_type_error] = @mod.errors[:type]
        redirect_to  :back
      end
    else
      flash[:error] = "Could not create the module. There were problems with the following fields: Content Type"
      if params[:mod][:module_title].empty?
        flash[:error] =+ "and Module Name can not be blank."
      end
      flash[:mod_title] = params[:mod][:module_title]
      flash[:mod_type] = params[:mod][:type]
      flash[:mod_title_error] = "" unless params[:mod][:module_title]
      flash[:mod_type_error] = ""
      redirect_to  :back
    end
  end

  def remove_module
    begin
      tab = find_tab
      resource = @tab.find_resource params[:mod], params[:type]
      tab.resources.delete resource
      redirect_to :back
    rescue ActiveRecord::RecordNotFound
      redirect_to :back and return
    end
  end

  def toggle_columns
    find_tab.toggle_columns
    redirect_to @parent
  end

  def reorder_modules
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
    find_tab.reorder_modules resource_ids.map(&:to_i)
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
