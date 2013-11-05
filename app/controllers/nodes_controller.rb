require 'will_paginate/array'

class NodesController < ApplicationController
  skip_before_filter :authorize, :only =>[:view]
  layout 'admin'

  def index
    @all  = params[:all]
    @list = params[:list] || 'mine'
    @sort = params[:sort] || 'name'
    @mods = @user.sort_mods(@sort, @list).paginate page: params[:page]
  end

  def show
    @mod = Node.find params[:id]
  end

  def edit
    @mod = Node.find params[:id]
  end

  def copy
    old_mod = Node.find params[:id]
    @new_mod = old_mod.copy
    if @new_mod.save
      create_and_add_node @user, @new_mod
      redirect_to edit_node_path(@new_mod)
    end
  end

  def new
  end

  def create
    begin
      @mod = Node.create mod_params
      @mod.slug = create_slug params[:module_title]
      if @mod.save
        create_and_add_node @user, @mod
        @mod.add_tags params[:tag_list]
        redirect_to edit_node_path(@mod)
      else
        render :new
      end
    rescue
      remove_instance_variable :@mod
      render :new
    end
  end

  def update
    @mod = Node.find params[:id]
    @mod.update_attributes mod_params
    render nothing: true
  end

  def destroy
    node = @user.find_node params[:id]
    @user.update_attribute(:node_id, nil) if @user.node_id == node.id
    if node.users.length == 1
      @user.nodes.delete node
      node.destroy
    else
      node.mod.update_attribute(:created_by, node.users.collect{|u| u.name}.at(1)) if node.mod.created_by.to_s == @user.name.to_s
      @user.nodes.delete node
    end
    redirect_to nodes_path
  end

  def globalize
    mod = find_mod params[:id]
    mod.toggle! :global
    redirect_to nodes_path
  end

  def publish
    mod = find_mod params[:id]
    mod.toggle! :published
    redirect_to nodes_path
  end

  def share
    @mod = @user.find_node params[:id]
    unless @mod
      redirect_to nodes_path and return
    end
    @user_list = User.order :name
    @mod_owners = @mod.users.uniq
  end

  def manage
    begin
      @mod = find_mod params[:id]
      @course_pages = @mod.get_pages
      @guides = @mod.get_guides
    rescue
      redirect_to :back
    end
  end

  def add_item
    session[:tabs] ||= []
    session[:tabs] << params[:tid] unless session[:tabs].include? params[:tid]
    render nothing: true
  end

  def add_to_item item_type
    session[:tabs] ||= []
    begin
      @mod = find_mod params[:id]
      @sort = params[:sort] ||= 'name'
      @items = @user.send "sort_#{ item_type }s", @sort
      @items = @items.paginate page: params[:page]
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index', :list=> 'mine' and return
    end
    if request.xhr?
      render :partial => "add_#{ item_type }_list", :layout => false
    elsif request.post?
      session[:tabs].each do |tid|
        tab = Tab.find tid
        tab.add_node params[:id]
      end
      session[:tabs] = nil
      flash[:message] = "#{@mod.module_title} successfully added to these guides."
      redirect_to manage_node_path(@mod)
    else
      @item_type = item_type
      render 'nodes/add_to_item'
    end
  end

  def add_to_guide
    add_to_item "guide"
  end

  def add_to_page
    add_to_item "page"
  end

  def share_update
    resource = @user.find_node params[:id]
    to_users = []
    if params[:users] != nil
      params[:users].each do |p|
        new_user = User.find(p)
        if new_user and resource.users.include?(new_user) == false
          new_user.nodes << resource
          to_users << new_user
        end
      end
      flash[:notice] = "User(s) successfully added and email notification sent."
      send_notices to_users, resource.label
    else
      flash[:notice] = "Please select at least one user to share with."
    end
    redirect_to :action => 'share',:id => resource.id
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
      @mod = find_mod params[:id]
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
      resource = @user.find_node params[:id]
    rescue Exception => e
      redirect_to :action => 'index', :list=> 'mine'
    else
      user = User.find params[:user]
      user.nodes.delete resource
      flash[:notice] = "User(s) successfully removed from editor list."
      redirect_to :action => 'share', :id => resource.id
    end
  end

  private

  def mod_params
    params.permit :module_title, :tag_list, :label, :content, :more_info, :global, :slug, :published
  end
end
