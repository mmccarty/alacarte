class PageController < ApplicationController
include ReservesScraper
before_filter :authorize
before_filter :current_page, :only =>[ :edit_reserves, :edit_databases,:save_databases, :sort, :toggle_columns,:add_modules,:edit_module, :new_module, :remove_module,:preview_module, :send_url]
before_filter :altered_pages
before_filter :module_types, :only =>[ :add_modules]
layout :select_layout

  
  def index
  #might get slow if listing more than 1000 pages
  #see http://wiki.rubyonrails.org/rails/pages/HowtoPagination
   @pcurrent = 'current'
   @subj_list = get_subjects
   sort = case params['sort']
             when "name"  then "subject"
             when "date"   then "updated_at, subject"
             when "publish" then "published, subject"
             when "archive"  then "archived, subject"
             when "name_reverse"  then "subject DESC"
             when "date_reverse"   then "updated_at DESC, subject"
             when "publish_reverse" then "published DESC, subject"
             when "archive_reverse"  then "archived DESC, subject"
             when " " then "subject, course_num, course_name"
           end
   #read and set the variables 
       page = (params[:page] ||= 1).to_i
       items_per_page = 15
       offset = (page - 1) * items_per_page
   #get the user's pages
       @pages = @user.pages.find(:all, :order => sort)
   #create a Paginator
       @which_pages = Paginator.new(self, @pages.length, items_per_page, page)          
   #only send a subset of @pages to the view
       @pages = @pages[offset..(offset + items_per_page - 1)]
       
   if request.xhr?
      render :partial => "pages_list", :layout => false 
    end
    
  end


  
  def create
      session[:page]= nil
      if request.post?
        @page =  Page.new
        @page.attributes = params[:page]
        @page.created_by = @user.name
        @page.resource_id = @user.rid  unless @user.rid.blank?
        if @page.save 
           session[:page] = @page.id
           @user.add_page(@page)
           redirect_to  :action => 'update', :id =>@page.id
        else
          flash[:error] = "Could not create the page. There were problems with the following fields:
                           #{@page.errors.full_messages.join(", ")}" 
        
          flash[:course_subj] = params[:page][:subject]
          flash[:course_name] = params[:page][:course_name]
          flash[:course_num] = params[:page][:course_num]
          flash[:course_term] = params[:page][:term]
          flash[:course_year] = params[:page][:year]
          flash[:course_sect] = params[:page][:sect_num]
          
           flash[:course_subj_error] = @page.errors[:subject]
          flash[:course_name_error] = @page.errors[:course_name]
          flash[:course_num_error] = @page.errors[:course_num]
          flash[:course_term_error] = @page.errors[:term]
          flash[:course_year_error] = @page.errors[:year]
          flash[:course_sect_error] = @page.errors[:sect_num]

         redirect_to :action => 'index'
        end 
      end
  end
  
  def new 
    session[:page]= nil
      if request.post?
        @page =  Page.new
        @page.attributes = params[:page]
        if @page.save 
           session[:page] = @page.id
           @user.add_page(@page)
           redirect_to  :action => 'update', :id =>@page.id
        else
         render :action => 'new'
        end 
      end
  end
  
  def update
     @subj_list = get_subjects
     @ucurrent = 'current'
     @resources = @user.contact_resources
    begin
      @page =  @user.pages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid page #{params[:id]}" )
      flash[:notice] = "You are tring to access something that either doesn't exist or you don't have access to."
      redirect_to  :action => 'index'
    else
      session[:page]= @page
    end
      @selected = @page.resource_id
      if request.post?
         @page.attributes = params[:page]
         @page.add_tags(params[:tags])
          @page.add_contact_module(params[:contact])
         if @page.save
           redirect_to :action => 'edit', :id =>@page.id 
         end
      end
  end
  
  def copy
     @ccurrent = 'current'
     @subj_list = get_subjects
     @resources = @user.contact_resources
    begin
      @page = @user.pages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid page #{params[:id]}" )
      flash[:notice] = "You are tring to access something that either doesn't exist or you don't have access to."
      redirect_to  :action => 'index'
    else
     @selected = @page.resource_id
    end
      if request.post?
         @new_page = @page.clone
         @new_page.attributes = params[:page]
         @new_page.published = false
         @new_page.created_by = @user.name
         if @new_page.save
            session[:page] = @new_page.id
            @user.add_page(@new_page)
            @page.modules.each  do |mod|
              mod_copy = mod.clone
              create_and_add_resource(@user,mod_copy,@new_page)
            end
           redirect_to  :action => 'edit'  , :id =>@new_page.id
         else
           flash[:error] = "Please edit the page title. A course page with this title already exists."
         end
     end
  end
  
  
  #edit page . Gets the modules and template
  def edit
    @ecurrent = 'current'
    begin
      @page = @user.pages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid page #{params[:id]}" )
      flash[:notice] = "You are tring to access something that either doesn't exist or you don't have access to."
      redirect_to  :action => 'index'
    else
    session[:page] = @page.id
    @mods = @page.page_resources
    if @page.template == 2
      @mods_left = []
      @mods_right = []
      @mods.each do |mod|
         if mod.position.odd?
            @mods_left << mod
         else
            @mods_right << mod
         end
      end
    end
   end
  end
  
  #Sort function for drag and drop  
def sort
   if params['left'] then  
    sortables = params['left']
    sortables.each do |id|
      page_resource = @page.page_resources.find(id)
      page_resource.update_attribute(:position, 2*sortables.index(id) + 1 )
    end
   
   elsif params['right'] then 
      sortables = params['right'] 
      sortables.each do |id|
        page_resource = @page.page_resources.find(id)
       page_resource.update_attribute(:position, 2*sortables.index(id) + 2 )
       end
   elsif params['full'] then 
     sortables = params['full'] 
     sortables.each do |id|
      page_resource = @page.page_resources.find(id)
     page_resource.update_attribute(:position, sortables.index(id) + 1 )
     end
   end
   render :nothing => true 
  end
  
  def recent_pages
    if request.post? and params[:altered_list]
      params[:altered_list].each do |pid|
         session[:page_list].delete(pid)
         break
      end
      if session[:page_list].empty?
        session[:page_list] = nil
        redirect_to :action => 'index'
      else
        page = @user.pages.find(session[:page_list].at(0))
        redirect_to :action => 'edit', :id => page, :sort =>'name'
      end
    else  
      redirect_to :back
    end
  end
  

   
  def add_modules
     @amcurrent = 'current'
      case params['sort']
             when "name"  then  sort = "module_title"  and reverse = "true"
             when "date"   then sort =  "updated_at"  and reverse = "true"
             when "type" then sort =  "content_type"  and reverse = "true"
             when "title_reverse"  then sort =  "module_title" and reverse = "false"
             when "date_reverse"   then sort =  "updated_at" and reverse = "false"
             when "type_reverse" then sort =  "content_type" and reverse = "false"
       end
       @mods =  @user.modules(sort, reverse) 
   #read and set the variables 
       page = (params[:page] ||= 1).to_i
       items_per_page = 15
       offset = (page - 1) * items_per_page
   #get the user's modules
   #create a Paginator
       @which_mods = Paginator.new(self, @mods.length, items_per_page, page)          
   #only send a subset of @pages to the view
       @mods = @mods[offset..(offset + items_per_page - 1)]
       @list = params[:list]
       if request.xhr? 
          render :partial => "shared/add_modules_list", :layout => false
       elsif request.post?
          params[:mod_list].each do |value|
               id = value.gsub(/[^0-9]/, '')
               type = value.gsub(/[^A-Za-z]/, '')
               resource = @user.find_resource(id,type)
               @page.add_resource(resource)
           end
          redirect_to :action => "edit", :id => @page.id
        end
  end


def new_module
  if request.post? and !params[:mod][:type].empty? and !params[:mod][:module_title].empty?
           @mod = create_module_object(params[:mod][:type])
           @mod.attributes = params[:mod]
           if @mod.save 
             create_and_add_resource(@user,@mod, @page)
             redirect_to  :action => 'edit_module' , :id =>@mod.id, :type => @mod.class
          else
            flash[:notice]="Could not create the new module. Please try again."
             redirect_to  :back
         end
   else
      flash[:notice]="Could not create the new module, maybe you forgot to select the module type. Please try again."
      redirect_to  :back
   end
end

def retrieve_reserves
    if request.xhr?
      #The scraper just wants the URI, not the entire html link tag.
      /href="(.*)"/.match(params[:title])
      link = $1 if $1
      
      if link
        reserves = search_reserves(nil, link)
        #we have to put the reserves somewhere "safe" across the AJAX request
        #so we tuck it into the session, and then erase it when we are done
        #saving our changes to the module
        @title = params[:title]
        
        /href="\/search?\/r(.*)\/.*"/.match(@title)
        @course_title = $1 if $1
        
        session[:reserves] = reserves
      end
      render :partial => "/page/reserved_titles", :locals => {:reserves => reserves} and return
    end
    redirect_to :action => :index
  end
  
 def edit_module
     @ecurrent = 'current'
     begin
      @mod = find_mod(params[:id], params[:type])
     rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid module #{params[:id]}" )
      flash[:notice] = "You are trying to access a module that doesn't yet exist."
      redirect_to  :action => 'index', :list=> 'mine'
    else
       #We need to pull the reserves available for this course when we edit it,
       #and then conditionally check the boxes in the view if that reserve is already
       #saved in the module.
       if @mod.class.to_s == "ReserveResource"
         redirect_to :action => 'edit_reserves', :id => @mod.id
      end
       if @mod.class.to_s == "DatabaseResource"
          redirect_to :action => 'edit_databases', :id => @mod.id
        end
     end
       if request.post?
         @mod.attributes = params[:mod] 
         if @mod.save
           if params[:comment_ids]
             Comment.delete(params[:comment_ids])
           end
           if params[:more]== 1
             @mod.update_attribute(:more_info, nil)
           end
           if params[:targets]
             targets = params[:targets]
             targets.each do |value|
                 target = LfTarget.create(:value => value)
                 @mod.lf_targets << target
             end
          end
            redirect_to :action => "edit" , :id =>@page.id
          end
     end 
 end
 
 def edit_reserves
    @ecurrent = 'current'
     begin
         @mod = find_mod(params[:id], "ReserveResource")
     rescue ActiveRecord::RecordNotFound
        logger.error("Attempt to access invalid module #{params[:id]}" )
        flash[:notice] = "You are trying to access a module that doesn't yet exist."
        redirect_to  :action => 'index', :list=> 'mine'
     else
       if @mod.course_title == nil #there was not more than one course when mod was created 
            @reserves = search_reserves("#{@page.subject} #{@page.course_num}")
       else #only get reserves for specific course
            @reserves = search_reserves(@mod.course_title)
       end
     end
     if request.post?
         @mod.attributes = params[:mod] 
         if @mod.save
           desired_reserves = []
           if params[:reserves]
             #if no box is checked in the view, no param is passed
             #get the tucked away reserves from the session if our searched for
             #reserves are actually courses.  The counterpart to this is found
             #in :retrieve_reserves. 
             @reserves = session[:reserves] if @reserves.first[:course]
             @reserves.each { |r| desired_reserves << r if params[:reserves].include?(r[:id].to_s) }
             session[:reserves] = nil 
            end
            @mod.update_attribute(:library_reserves, desired_reserves)
            redirect_to :action => "edit" , :id =>@page.id
        end
     end
 end
 
 def edit_databases
     @ecurrent = 'current'
     begin
      @mod = find_mod(params[:id], "DatabaseResource")
     rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid module #{params[:id]}" )
      flash[:notice] = "You are trying to access a module that doesn't yet exist."
      redirect_to  :action => 'index', :list=> 'mine'
    else
       @letter = params[:sort] ? params[:sort] : "A" 
       @dbs = Dod.sort(@letter)
    end  
    if request.xhr? 
      render :partial => "shared/a_z_list", :layout => false
    elsif request.post? and params[:db_list]
      params[:db_list].each do |db_id|
        dod = Dod.find_by_id(db_id)
        @mod.add_dod(dod)
      end
      redirect_to  :action => 'edit_databases', :id =>@mod.id
    end
  end
  
  def save_databases
     begin
      @mod = find_mod(params[:id], "DatabaseResource")
     rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid module #{params[:id]}" )
      flash[:notice] = "You are trying to access a module that doesn't yet exist."
      redirect_to  :action => 'index', :list=> 'mine'
    else
       @mod.update_attributes( params[:mod]) 
       @mod.database_dods.each { |t| t.attributes = params[:database_dod][t.id.to_s] }  
        if params[:db_remove_list]
        params[:db_remove_list].each do |did|
           dod = @mod.dods.find(did)
           @mod.dods.delete(dod)
        end   
      end
       @mod.database_dods.each(&:save!)
         redirect_to :action => "edit" , :id =>@page.id
    end
  end
 
 #removes a module from a page.
  def remove_module
     resource = @page.find_resource(params[:id],params[:type] )
     @page.resources.delete(resource)
     redirect_to :back
  end
  
 def preview_module
   begin
      @mod = find_mod(params[:id],params[:type] )
    rescue Exception => e
      logger.error("Exception in show: #{e}" )
      flash[:notice] = "Invalid module"
      redirect_to :back
    else
      @title = "Previewing Module #{@mod.module_title}"
     end
 end

  def publish
    begin
      page = @user.pages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access You are tring to access something that either doesn't exist or you don't have access to. #{params[:id]}" )
      flash[:notice] = "You are tring to access something that either doesn't exist or you don't have access to."
      redirect_to :action => 'index'
     else
       page.toggle!(:published)
       page.update_attribute(:archived, false)
       redirect_to  :back
     end
   end
  
   def archive
     begin
      page = @user.pages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access You are tring to access something that either doesn't exist or you don't have access to. #{params[:id]}" )
      flash[:notice] = "You are tring to access something that either doesn't exist or you don't have access to."
      redirect_to  :action => 'index'
     else
       page.toggle!(:archived)
       page.update_attribute(:published, false)
       redirect_to  :back
     end
   end

 def share
  begin
      @page = @user.pages.find(params[:id])
  rescue ActiveRecord::RecordNotFound
      logger.error("You are tring to access something that either doesn't exist or you don't have access to. #{params[:id]}" )
      flash[:notice] = "You are tring to access something that either doesn't exist or you don't have access to."
      redirect_to :action => 'index'
  else
    @title_mssg = "Share #{@page.header_title}"
    @user_list = User.find(:all, :order => "name")
    @page_owners = @page.users
  end
  
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
              Notifications.deliver_share_page(new_user.email,@user.email,@page.search_title)
           rescue Exception => e
              logger.error("Exception in share module: #{e}}" )
              flash[:notice] = "Could not send email"
              redirect_to  :action => "share", :id =>@page and return
            end
        end
       end
         flash[:notice] = "User(s) successfully added."
          redirect_to :action => 'share', :id =>@page
       else
          flash[:notice] = "Please select at least one user to share with."
          redirect_to :action => 'share', :id =>@page
      end
    end  
 end
 
 def send_url
 #send the page's URL to stakeholders via email
       @title_mssg = "Email URL for #{@page.header_title}"
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
              logger.error("Exception in share module: #{e}}" )
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
      logger.error("Attempt to access You are tring to access something that either doesn't exist or you don't have access to. #{params[:id]}" )
      flash[:notice] = "You are tring to access something that either doesn't exist or you don't have access to."
      redirect_to :action => 'index'
    else
    if page.users.length < 2 # if only one owner delete the page
       @user.pages.delete(page)
       page.destroy
    else # just delete the association
         @user.pages.delete(page)
    end  
    redirect_to :action => 'index', :page => params[:page]
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
 
  
  private
   
  
  def select_layout
   if ['index'].include?(action_name) 
     "dashboard" 
   elsif ['preview_module'].include?(action_name)
     "popup"
   else 
     "overview"
   end
  end
end
