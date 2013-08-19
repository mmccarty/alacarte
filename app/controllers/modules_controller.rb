  class ModulesController < ApplicationController
  include Paginating
  skip_before_filter :authorize, :only =>[:view]
  before_filter :module_types, :except => [:view]
  layout 'admin'

  def index
    @all  = params[:all]
    @list = params[:list] || 'mine'
    @sort = params[:sort] || 'name'
    @mods = @user.sort_mods(@sort, @list).paginate page: params[:page]
  end

  def show
    delegate_to :show
  end

  def edit
    delegate_to :edit
  end

  def copy
    delegate_to :copy
  end

  def new
  end

  def create
    begin
      @mod = create_module_object params[:mod][:type]
      @mod.update_attributes params[:mod]
      @mod.slug = create_slug params[:mod][:module_title]
      if @mod.save
        create_and_add_resource @user, @mod
        @mod.add_tags params[:mod][:tag_list]
        redirect_to edit_module_path(@mod, type: @mod.class)
      else
        render :new
      end
    rescue
      remove_instance_variable :@mod
      render :new
    end
  end

  def destroy
    resource = @user.find_resource params[:id], params[:type]
    @user.update_attribute(:resource_id, nil) if @user.resource_id == resource.id
    if resource.users.length == 1
      @user.resources.delete resource
      resource.delete_mods
      resource.destroy
    else
      resource.mod.update_attribute(:created_by, resource.users.collect{|u| u.name}.at(1)) if resource.mod.created_by.to_s == @user.name.to_s
      @user.resources.delete resource
    end
    redirect_to modules_path
  end

  def globalize
    mod = find_mod params[:id], params[:type]
    mod.toggle! :global
    redirect_to modules_path
  end

  def publish
    mod = find_mod params[:id], params[:type]
    mod.toggle! :published
    redirect_to modules_path
  end

  def share
    resource = @user.find_resource params[:id], params[:type]
    unless resource
      redirect_to modules_path and return
    end
    @mod = resource.mod
    @user_list = User.order :name
    @mod_owners = resource.users.uniq
  end

  def manage
    begin
      @mod = find_mod params[:id], params[:type]
      @course_pages = @mod.get_pages if @local.guides_list.include?('pages')
      @guides = @mod.get_guides if @local.guides_list.include?('guides')
      @tutorials = nil #@mod.get_tutorials if @local.guides_list.include?('tutorials')
    rescue
      redirect_to :back
    end
  end

  def add_item
    session[:tabs] ||= []
    session[:tabs] << params[:tid] unless session[:tabs].include? params[:tid]
    render nothing: true
  end

  def add_tutorial
    session[:units] ||= []
    session[:units] << params[:tid] unless session[:units].include? params[:tid]
    render nothing: true
  end

  def add_to_item item_type
    session[:tabs] ||= []
    begin
      @mod = find_mod params[:id], params[:type]
      @sort = params[:sort] ||= 'name'
      @items = @user.send "sort_#{ item_type }s", @sort
      @items = send "paginate_#{ item_type }s", @items, (params[:page] ||= 1), @sort
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index', :list=> 'mine' and return
    end
    if request.xhr?
      render :partial => "add_#{ item_type }_list", :layout => false
    elsif request.post?
      session[:tabs].each do |tid|
        tab = Tab.find tid
        tab.add_module params[:id], params[:type]
      end
      session[:tabs] = nil
      flash[:message] = "#{@mod.module_title} successfully added to these guides."
      redirect_to manage_module_path(@mod, type: @mod.class)
    else
      @item_type = item_type
      render "modules/add_to_item"
    end
  end

  def add_to_guide
    add_to_item "guide"
  end

  def add_to_page
    add_to_item "page"
  end

  def add_to_tutorial
    session[:units] ||= []
    begin
      @mod = find_mod(params[:id],params[:type])
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index', :list=> 'mine' and return
    else
      @sort = params[:sort] ||= 'name'
      @tutorials =  @user.sort_tutorials @sort
      @tutorials = paginate_list @tutorials, (params[:page] ||= 1), @sort
      if request.xhr?
        render :partial => "add_tutorial_list", :layout => false
      elsif request.post?
        session[:units].each do |tid|
          unit = Unit.find tid
          unit.add_module params[:id], params[:type]
        end
        session[:units] = nil
        flash[:message] = "#{@mod.module_title} successfully added these tutorials."
        redirect_to manage_module_path(@mod, type: @mod.class)
      end
    end
  end

  def share_update
    resource = @user.find_resource params[:id], params[:type]
    to_users = []
    if params[:users] != nil
      params[:users].each do |p|
        new_user = User.find(p)
        if new_user and resource.users.include?(new_user) == false
          new_user.add_resource(resource)
          to_users << new_user
        end
      end
      flash[:notice] = "User(s) successfully added and email notification sent."
      send_notices to_users, resource.mod.label
    else
      flash[:notice] = "Please select at least one user to share with."
    end
    redirect_to :action => 'share',:id => resource.mod.id, :type => resource.mod.class
  end

  def send_notices users, mod_title
    users.each do |p|
      new_user = User.find p
      Notifications.share_module(new_user.email, @user.email, mod_title, @user.name).deliver
      flash[:notice] = "User(s) successfully added and email notification sent."
    end
  end

  def view
    @class ='thumbnail'
    @style ='width:255px; height:220px;'
    begin
      @mod = find_mod params[:id], params[:type]
    rescue Exception => e
      redirect_to :back
    end
    @preview = true if @mod.class == QuizResource
    respond_to do |format|
      format.html {render :layout => 'popup'}
    end
  end

  def remove_user_from_mod
    begin
      resource = @user.find_resource params[:id], params[:type]
    rescue Exception => e
      redirect_to :action => 'index', :list=> 'mine'
    else
      user = User.find params[:user]
      user.resources.delete resource
      flash[:notice] = "User(s) successfully removed from editor list."
      redirect_to :action => 'share', :id => resource.mod.id, :type => resource.mod.class
    end
  end

  private

  RESOURCE_CONTROLLER = {
      'BookResource'          => :book,
      'CommentResource'       => :comment_resources,
      'DatabaseResource'      => :database_resources,
      'InstResource'          => :inst_resources,
      'LibResource'           => :lib_resources,
      'MiscellaneousResource' => :miscellaneous_resources,
      'QuizResource'          => :quiz_resources,
      'ReserveResource'       => :reserve,
      'RssResource'           => :rss_resources,
      'UploaderResource'      => :uploader,
      'UrlResource'           => :url_resources
  }

  def delegate_to action
    redirect_to controller: RESOURCE_CONTROLLER[params[:type]], action: action, id: params[:id]
  end
end
