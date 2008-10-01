class AdminController < ApplicationController
  before_filter :authorize_admin
  before_filter :current_user, :only =>[:destroy_page, :assign_page,:archive_page,:destroy_guide, :assign_guide ]

   def tools
      @tcurrent = 'current'
      @user_count = User.count
      @page_count = Page.count
      @guide_count = Guide.count
      @ppage_count = Page.find(:all, :conditions => ["published=?", true]).size
       @apage_count = Page.find(:all, :conditions => ["archived=?", true]).size
      @pguide_count = Guide.find(:all, :conditions => ["published=?", true]).size
   end
   
   def register
     @user = User.new
     if request.post? 
        @user = User.new(params[:user])
        @user.role = params[:user][:role]
        flash[:notice] = "User successfully added."
        redirect_to(:action => 'users')  if @user.save
     end
   end
   
   def users
     session[:cuser]= nil
    @ucurrent = 'current'
    @user_pages, @users = paginate :users, :per_page => 30
  end
  
  def customize_layout
     @local = Local.find(:first)
   if request.post?
     @local.update_attributes(params[:local])
     redirect_to(:action => 'view_customizations')  if @local.save
   end
  end
  
  def view_customizations
    @locals = Local.find(:all)
  end
  
  def customize_search
     @local = Local.find(:first)
   if request.post?
     @local.update_attributes(params[:local])
     redirect_to(:action => 'view_customizations')  if @local.save
   end
  end
 
 
  
  def list_pages
    @all_pages, @pages = paginate :pages, :per_page => 30
  end
  
 
 def edit
   @user = User.find(params[:id])
 end
 
 def update
    @user = User.find(params[:id])
    if @user.update_attribute(:name, params[:user][:name])and @user.update_attribute(:email, params[:user][:email])and @user.update_attribute(:role, params[:user][:role])
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'users'
    else
      render :action => 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
     flash[:notice] = "User(s) successfully deleted."
    redirect_to :action => 'users'
  end
   
 def guides
   @user = User.find(params[:id])
   session[:cuser] = @user
   @guides= @user.guides
   @count = @guides.size
 end
 
  def pages
   @user = User.find(params[:id])
   session[:cuser] = @user
   @pages = @user.pages
   @count = @pages.size
 end
 
 def destroy_page
   page = @user.pages.find(params[:id])
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
   page = @user.pages.find(params[:id])
   page.toggle!(:archived)
   page.update_attribute(:published, false)
   redirect_to  :back
 end
 
 def assign_page
    @page = @user.pages.find(params[:id])
    @user_list = User.find(:all, :order => "name")
    @page_owners = @page.users
    if request.post?
       if params[:users]
        params[:users].each do |p|
          new_user = User.find(p)
          if new_user and !@page_owners.include?(new_user)
            @page.add_user(new_user)
            @page.resources.each  do |resource|
               new_user.resources << resource
           end
           begin
              Notifications.deliver_share_page(new_user.email,@admin.email,@page.search_title)
           rescue Exception => e
              logger.error("Exception in share module: #{e}}" )
              flash[:notice] = "Could not send email"
              redirect_to  :action => "assign_page", :id =>@page and return
            end
        end
       end
         flash[:notice] = "User(s) successfully added."
          redirect_to :action => 'assign_page', :id =>@page
       else
          flash[:notice] = "Please select at least one user to share with."
          redirect_to :action => 'assign_page', :id =>@page
      end
    end
 end
 

  def destroy_guide
    guide = @user.guides.find(params[:id])
   if guide.users.length == 1 # if only one owner delete the page
       @user.guides.delete(guide)
       guide.destroy
    else # just delete the association
       @user.guides.delete(guide)
    end  
     flash[:notice] = "Guide successfully deleted."
    redirect_to :back
 end
 
 def assign_guide
    @guide = @user.guides.find(params[:id])
    @user_list = User.find(:all, :order => "name")
    @guide_owners = @guide.users
    if request.post?
           if params[:users]
        params[:users].each do |p|
          new_user = User.find(p)
          if new_user and @guide_owners.include?(new_user)== false
           new_user.add_guide( @guide)
            @guide.tabs.each  do |tab|
              tab.tab_resources.each do |tr|
                new_user.resources << tr.resource
              end 
            end
            begin
              Notifications.deliver_share_guide(new_user.email,@user.email,@guide.guide_name)
            rescue Exception => e
              logger.error("Exception in share guide: #{e}}" )
              flash[:notice] = "Could not send email"
              redirect_to  :action => "assign_guide" and return 
            end
         end
       end
          flash[:notice] = "User(s) successfully added."
          redirect_to :action => 'assign_guide', :id =>@guide.id
      else
        flash[:notice] = "Please select at least one user to share with."
        redirect_to :action => 'assign_guide', :id => @guide.id
      end

    end
 end
 
 def remove_user_from_guide
    guide = Guide.find(params[:id])
    user = guide.users.find_by_id(params[:uid])
    guide.users.delete(user) 
    redirect_to :action => 'assign_guide', :id => guide
 end
 
 def remove_user_from_page
      page = Page.find(params[:id])
      user = page.users.find_by_id(params[:uid])
      page.users.delete(user) 
      redirect_to :action => 'assign_page', :id => page
 end
 
 def email_list
   users = User.find(:all)
   @emails = users.collect(&:email).join(', ') 
 end

end