class AdminController < ApplicationController
  before_filter :authorize_admin

  def index
    @user_count      = User.count
    @page_count      = Page.count
    @guide_count     = Guide.count
    @tutorial_count  = Tutorial.count
    @ppage_count     = Page.where(published: true).count
    @apage_count     = Page.where(archived: true).count
    @pguide_count    = Guide.where(published: true).count
    @ptutorial_count = Tutorial.where(published: true).count
  end

  def auto_archive
    pages = Page.where(:published => true)
    guides = Guide.where(:published => true)
    tutorials = Tutorial.where(:published => true)
    pages.each do |page|
      if page.updated_at < Time.now.months_ago(6)
        page.toggle!(:archived)
        page.update_attribute(:published, false)
      end
    end
    guides.each do |guide|
      if guide.updated_at < Time.now.months_ago(12)
        guide.toggle!(:published)
      end
    end
    tutorials.each do |tutorial|
      if tutorial.updated_at < Time.now.months_ago(12)
        tutorial.toggle!(:archived)
        tutorial.update_attribute(:published, false)
      end
    end
    redirect_to :back
  end

  def guides
    @user = User.find(params[:id])
    session[:author] = @user.id
    @guides= @user.guides
    @count = @guides.size
  end

  def destroy_guide
    guide = Guide.find(params[:id])
    @user = User.find(session[:author])
    if guide.users.length == 1 # if only one owner delete the page
      @user.guides.delete(guide)
      guide.destroy
    else # just delete the association
      @user.guides.delete(guide)
    end
    flash[:notice] = "Guide successfully deleted."
    redirect_to :back
  end

  def archive_guide
    guide = Guide.find(params[:id])
    guide.update_attribute(:published, false)
    redirect_to  :back
  end

  def assign_guide
    begin
      @guide = Guide.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => 'tools'
    else
      session[:guide] = @guide.id
      @user_list = User.order("name")
      @guide_owners = @guide.users
    end
  end

  def guide_update
    @guide = Guide.find(params[:id])
    to_users = []
    if params[:users] != nil
      params[:users].each do |p|
        new_user = User.find(p)
        if new_user and !@guide.users.include?(new_user)
          @guide.share(new_user.id,nil) #add_guide_tabs(@guide)
          to_users << new_user
        end
      end
      flash[:notice] = "User(s) successfully added and email notification sent."
      guide_send_notices(to_users, @guide)
    else
      flash[:notice] = "Please select at least one user to share with."
    end
    redirect_to :action => 'assign_guide', :id => @guide.id and return
  end

  def guide_send_notices(users,guide)
    @guide = Guide.find(params[:id])
    users.each do |p|
      new_user = User.find(p)
      begin
        Notifications.deliver_share_guide(new_user.email,@user.email,@guide.guide_name) #, @user.name)
      rescue Exception => e
        flash[:notice] = "User(s) successfully added. Could not send email"
      else
        flash[:notice] = "User(s) successfully added and email notification sent."
      end
    end
  end

  def remove_user_from_guide
    begin
      @guide = Guide.find(params[:id])
    rescue Exception => e
      redirect_to :action => 'tool', :list=> 'mine'
    else
      user = @guide.users.find_by_id(params[:uid])
      @guide.update_attribute(:created_by, @guide.users.at(1).name) if @guide.created_by.to_s == user.name.to_s
      user.delete_guide_tabs(@guide)
      flash[:notice] = "User(s) successfully removed."
      redirect_to :action => 'assign_guide', :id => @guide
    end
  end

  def pages
    @user = User.find(params[:id])
    session[:author] = @user.id
    @pages = @user.pages
    @count = @pages.size
  end

  def destroy_page
    page = Page.find(params[:id])
    @user = User.find(session[:author])
    if page.users.length == 1 # if only one owner delete the page
      @user.pages.delete(page)
      page.destroy
    else # just delete the association
      @user.pages.delete(page)
    end
    flash[:notice] = "Page successfully deleted."
    redirect_to :back
  end

  def archive_page
    page = Page.find(params[:id])
    page.toggle!(:archived)
    page.update_attribute(:published, false)
    redirect_to  :back
  end

  def assign_page
    begin
      @page = Page.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => 'tools' and return
    else
      session[:page] = @page.id
      @user_list = User.order("name")
      @page_owners = @page.users
    end
  end

  def page_update
    @page = Page.find(params[:id])
    to_users = []
    if params[:users] != nil
      params[:users].each do |p|
        new_user = User.find(p)
        if new_user and !@page.users.include?(new_user)
          @page.share(new_user.id,nil) #user.add_page_tabs(@page)
          to_users << new_user
        end
      end
      flash[:notice] = "User(s) successfully added."
      page_send_notices(to_users, @page)
    else
      flash[:notice] = "Please select at least one user to share with."
    end
    redirect_to :action => 'assign_page', :id => @page.id and return
  end

  def page_send_notices(users, page)
    @page = Page.find(params[:id])
    users.each do |p|
      new_user = User.find(p)
      begin
        Notifications.deliver_share_guide(new_user.email,@user.email,@page.header_title, @user.name)
      rescue Exception => e
        flash[:notice] = "User(s) successfully added. Could not send email"
      else
        flash[:notice] = "User(s) successfully added and email notification sent."
      end
    end
  end

  def remove_user_from_page
    begin
      page = Page.find(params[:id])
    rescue Exception => e
      logger.error("Exception in remove_from_user: #{e}" )
      redirect_to :action => 'index', :list=> 'mine'
    else
      user = page.users.find_by_id(params[:uid])
      page.update_attribute(:created_by, page.users.at(1).name) if page.created_by.to_s == user.name.to_s
      user.delete_page_tabs(page)
      flash[:notice] = "User(s) successfully removed."
      redirect_to :action => 'assign_page', :id => page
    end
  end

  def tutorials
    @user = User.find(params[:id])
    session[:author] = @user.id
    @tutorials = @user.tutorials
    @count = @tutorials.size
  end

  def destroy_tutorial
    tutorial = Tutorial.find(params[:id])
    @user = User.find(session[:author])
    if tutorial.users.length == 1 # if only one owner delete the tutorial
      @user.tutorials.delete(tutorial)
      tutorial.destroy
    else # just delete the association
      @user.tutorials.delete(tutorial)
    end
    flash[:notice] = "Tutorial successfully deleted."
    redirect_to :back
  end

  def archive_tutorial
    tutorial = Tutorial.find(params[:id])
    tutorial.toggle!(:archived)
    tutorial.update_attribute(:published, false)
    redirect_to  :back
  end

  def assign_tutorial
    begin
      @tutorial = Tutorial.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'tools' and return
    else
      session[:tutorial] = @tutorial.id
      @user_list = User.order("name")
      @owners = @tutorial.users
    end
  end

  def tutorial_update
    to_users = []
    @tutorial =  Tutorial.find(params[:id])
    if params[:users] != nil
      params[:users].each do |p|
        new_user = User.find(p)
        if new_user and !@tutorial.users.include?(new_user)
          @tutorial.share(1, new_user, params[:copy])
          to_users << new_user
        end
      end
      flash[:notice] = "Tutorial Shared."
      url = url_for :controller => 'ort', :action => 'index', :id => @tutorial
      @message =
        "I've assigned #{@tutorial.full_name} to you. The link to the tutorial is: #{url} .  - admin "
      tutorial_send_notices(to_users,  @message) unless to_users.blank?
    else
      flash[:notice] = "Please select at least one user to share with."
    end
    redirect_to :action => 'assign_tutorial', :id => @tutorial.id and return
  end

  def tutorial_send_notices(users, message)
    users.each do |p|
      user =  User.find(p)
      begin
        Notifications.deliver_share_tutorial(user.email,@user.email, message)
      rescue Exception => e
        flash[:notice] = "Tutorial Shared. Could not send email"
      else
        flash[:notice] = "User(s) successfully added and email notification sent."
      end
    end
  end

  def remove_user_from_tutorial
    begin
      @tutorial =  Tutorial.find(params[:id])
    rescue Exception => e
      redirect_to :action => 'tools' and return
    else
      user = User.find(params[:uid])
      @tutorial.update_attribute(:created_by, @tutorial.users.at(1).id) if @tutorial.created_by.to_s == @user.id.to_s
      @tutorial.remove_from_shared(user)
      flash[:notice] = "User(s) successfully removed."
      redirect_to :action => 'assign_tutorial', :id => @tutorial
    end
  end

  def customize_layout
    if request.post?
      @local.update_attributes(params[:local])
      redirect_to(:action => 'view_customizations')  if @local.save
    end
  end

  def view_customizations
  end

  def customize_content_types
    @guide_types = [['Course Guides', 'pages'], ['Subject Guides', 'guides'], ['Research Tutorials', 'tutorials']]
    @types = MODULES
    @selected = @local.types_list
    @selected_guides = @local.guides_list
    if request.post?
      @local.update_attributes(params[:local])
      redirect_to(:action => 'view_customizations')  if @local.save
    end
  end

  def customize_admin_email
    if request.post?
      @local.update_attributes(params[:local])
      redirect_to(:action => 'view_customizations')  if @local.save
    end
  end
end
