class PagesController < ApplicationController
  include Paginating
  layout 'admin'

  def index
    @subj_list = Subject.get_subjects
    @sort = params[:sort] || 'name'
    @search_value ='Search My Pages'
    @pages = @user.sort_pages(@sort)
    @pages = paginate_pages(@pages, params[:page] ||= 1,@sort)
  end

  def show
    begin
      @page = @user.pages.find params[:id]
      @tabs = @page.tabs
      if @tabs.blank?
        @page.create_home_tab
        @tabs = @page.tabs
      end
      if session[:current_tab]
        @tab = @tabs.select { |t| t.id == session[:current_tab].to_i }.first
      end
      unless @tab
        @tab = @tabs.first
        session[:current_tab] = @tab.id
      end
      if @tab
        session[:current_tab] = @tab.id
        if @tab.template == 2
          @mods_left  = @tab.left_resources
          @mods_right = @tab.right_resources
        else
          @mods = @tab.tab_resources
        end
      else
        flash[:notice] = "There are critical errors on the guide. Consider deleting this guide."
        redirect_to  :action => 'index' and return
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to pages_path and return
    end
  end

  def new
    @page = Page.new
    @subj_list = Subject.get_subjects
    custom_page_data
  end

  def create
    page = Page.new params[:page]
    page.add_subjects params[:subjects]
    if page.save
      @user.add_page page
      page.create_home_tab
      redirect_to page
    end
  end

  def template
    @pages = Page.all
  end

  def edit
    @subj_list = Subject.get_subjects
    custom_page_data
    begin
      @page =  @user.pages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index' and return
    else
      @selected = @page.subjects.collect{|s| s.id}
      flash[:course_term] = @page.term
    end
  end

  def update
    @page = @user.pages.find params[:id]
    @page.update_attributes params[:page]
    #@page.add_subjects params[:subjects]
    if @page.save
      redirect_to @page
    else
      render :edit
    end
  end

  def copy
    session[:page]= nil
    session[:current_tab] = nil
    @ucurrent = 'current'
    @subj_list = Subject.get_subjects
    begin
      @page = @user.pages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index' and return
    else
      @selected = @page.subjects.collect{|s| s.id}
    end
    if request.post?
      @new_page = @page.clone
      @new_page.attributes = params[:page]
      @new_page.published = false
      @new_page.add_subjects(params[:subjects])
      if @new_page.save
        session[:page] = @new_page.id
        @user.add_page(@new_page)
        if params[:options]=='copy'
          logger.debug("in copy")
          @new_page.copy_resources(@user.id, @page.tabs)
        else
          logger.debug("not in copy")
          @new_page.copy_tabs(@page.tabs)
        end
        session[:current_tab] = @new_page.tabs.first.id
        redirect_to  :action => 'edit'  , :id =>@new_page.id
      else
        flash[:error] = "Please edit the page title. A course page with this title already exists."
      end
    end
  end

  def edit_contact
    begin
      @page = @user.pages.find params[:id]
      @tab = @page.tabs.first
    rescue ActiveRecord::RecordNotFound
      redirect_to pages_path and return
    else
      if request.put?
        @page.update_attributes params[:page]
        if @page.save
          flash[:notice] = "The Contact Module was successfully changed."
          redirect_to @page and return
        end
      else
        @resources = @user.contact_resources.map { |resource| [resource.mod.label, resource.id] }
      end
    end
  end

  def edit_relateds
    begin
      @page = @user.guides.find params[:id]
      @tab = @page.tabs.first
    rescue ActiveRecord::RecordNotFound
      redirect_to guides_path and return
    end
    if request.put?
      @page.add_related_guides params[:relateds] if params[:relateds]
      if @page.save
        flash[:notice] = "The guides were successfully related"
        redirect_to @page and return
      end
    else
      @guides   = Guide.published_guides
      @relateds = @page.related_guides.map &:id
    end
  end

  def remove_related
    @page.delete_relateds(params[:gid]) if params[:gid]
    redirect_to :action => 'edit_relateds'
  end

  def suggest_relateds
    @relateds = @page.suggested_relateds
    @guides = Guide.published_guides
    render :partial => "relateds", :layout => false
  end

  def publish
    begin
      page = @user.pages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => 'index' and return
    else
      page.toggle!(:published)
      page.update_attribute(:archived, false)
      if request.xhr?
        @sort = params[:sort] #set the sort variable to make sure the proper sort class is set for the updated row
        render :partial => "index_row" ,:locals => {:id => page, :page => params[:page], :sort => @sort , :all => params[:all]}
      else
        redirect_to :back, :page => params[:page], :sort => params[:sort]
      end
    end
  end

  def archive
    begin
      page = @user.pages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index' and return
    else
      page.toggle!(:archived)
      page.update_attribute(:published, false)
      if request.xhr?
        @sort = params[:sort] #set the sort variable to make sure the proper sort class is set for the updated row
        render :partial => "index_row" ,:locals => {:id => page, :page => params[:page], :sort => @sort , :all => params[:all]}
      else
        redirect_to :back, :page => params[:page], :sort => params[:sort]
      end
    end
  end

  def set_owner
    begin
      @page = @user.pages.find(params[:id])
    rescue
      redirect_to :action => 'index', :list=> 'mine' and return
    end
    @owner = User.find(params[:uid])
    @page.update_attribute(:created_by, @owner.name)
    @page_owners = @page.users
    if request.xhr?
      render :partial => 'owners', :layout => false
    else
      redirect_to :action => 'share', :id => @page.id
    end
  end

  def share
    @scurrent = 'current'
    begin
      @page = @user.pages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => 'index' and return
    else
      session[:page] = @page.id
      session[:current_tab] = @page.tabs.first.id
      @user_list = User.order("name")
      @page_owners = @page.users
      url = url_for :controller => 'ica', :action => 'index', :id => @page
      @message =
        "I've shared #{@page.header_title} with you. The link to the pagel is: #{url} .  -#{@user.name} "
    end
  end

  def share_update
    @page = @user.pages.find(params[:id])
    to_users = []
    if params[:users] != nil
      params[:users].each do |p|
        new_user = User.find(p)
        if new_user and !@page.users.include?(new_user)
          @page.share(new_user.id,params[:copy]) #user.add_page_tabs(@page)
          to_users << new_user
        end
      end
      flash[:notice] = "User(s) successfully added."
      send_notices(to_users, params[:body]) if params[:body]
    else
      flash[:notice] = "Please select at least one user to share with."
    end
    redirect_to :action => 'share', :id => @page.id and return
  end

  def send_notices(users, message)
    users.each do |p|
      user =  User.find(p)
      begin
        Notifications.deliver_share_tutorial(user.email,@user.email, message)
      rescue Exception => e
        flash[:notice] = "Page Shared. Could not send email"
      else
        flash[:notice] = "User(s) successfully added and email notification sent."
      end
    end
  end

  #remove a user from the list of editors via share page
  def remove_user_from_page
    begin
      user = @page.users.find_by_id(params[:id])
    rescue Exception => e
      redirect_to :action => 'index', :list=> 'mine'
    else
      @page.update_attribute(:created_by, @page.users.at(1).name) if @page.created_by.to_s == @user.name.to_s
      user.delete_page_tabs(@page)
      flash[:notice] = "User(s) successfully removed."
      redirect_to :action => 'share', :id => @page
    end
  end

  #send the page's URL to stakeholders via email
  def send_url
    @sucurrent = 'current'
    #send the page's URL to stakeholders via email
    @page_url = url_for :controller => 'ica', :action => 'index', :id => @page
    @message =
      "A new library course guide has been created for #{@page.header_title}. The link to the page is: #{@page_url}. Please inform your students of the page and include the link in your course material.
Please contact me if you have any questions or suggestions.
-#{@user.name} "
    if request.post?
      if params[:email] and params[:body]
        begin
          Notifications.deliver_send_url(params[:email],@user.email,params[:body])
        rescue Exception => e
          flash[:notice] = "Could not send email"
          redirect_to  :action => "send_url" and return
        else
          flash[:notice]  = "The URL was successfully emailed."
          redirect_to :action => "send_url"
        end
      end
    end
  end

  def destroy
    begin
      page = Page.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => 'index' and return
    else
      if page.users.length == 1 # if only one owner delete the page
        @user.pages.delete(page)
        page.destroy
      else # just delete the association
        page.update_attribute(:created_by, page.users.at(1).name) if page.created_by.to_s == @user.name.to_s
        @user.pages.delete(page)
      end
      if request.xhr?
        render :text => "" #delete the table row by sending back a blank string.  The <tr> tags still exist though
      else
        redirect_to :back, :page => params[:page], :sort => params[:sort]
      end
    end
  end

  #sets the template
  def toggle_columns
    if @page.template == 2
      @page.update_attribute(:template, 1)
    else
      @page.update_attribute(:template, 2)
    end
    redirect_to :action => "edit" , :id => @page
  end
end
