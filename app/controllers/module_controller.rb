#Controller for the tool's page creation view. These are CRUD actions for a resource. 
# An authorization filter ensures users are logged in and only working with their resources.
# The current resource that is being worked on is stored in a required session variable. The current resource
#filter sets @resource.


class ModuleController < ApplicationController
  include ReservesScraper
  before_filter :authorize, :except => [:more_info]
  before_filter :module_types, :clear_page_sessions, :clear_guide_sessions
  
  layout :select_layout
  
  def index
  #might get slow if listing more than 1000 pages
  #see http://wiki.rubyonrails.org/rails/pages/HowtoPagination
    @mcurrent = 'current'
    case params['sort']
             when "name"  then  sort = "label"  and reverse = "true"
             when "date"   then sort =  "updated_at"  and reverse = "true"
             when "type" then sort =  "content_type"  and reverse = "true"
             when "author"  then sort =  "created_by"  and reverse = "true"
             when "name_reverse"  then sort =  "label" and reverse = "false"
             when "date_reverse"   then sort =  "updated_at" and reverse = "false"
             when "type_reverse" then sort =  "content_type" and reverse = "false"
             when "author_reverse"  then sort =  "created_by" and reverse = "false"
             when " " then sort =  "label, updated_at" and reverse = "true"
           end
     @mods = case params[:list]
            when "mine" then @user.modules(sort, reverse) 
            when "global" then Resource.global_list(sort, reverse)
     end
  
   #read and set the variables 
       page = (params[:page] ||= 1).to_i
       @page = page
       items_per_page = 15
       offset = (page - 1) * items_per_page
   #get the user's modules
   #create a Paginator
       @which_mods = Paginator.new(self, @mods.length, items_per_page, page)          
   #only send a subset of @pages to the view
       @mods = @mods[offset..(offset + items_per_page - 1)]
       @list = params[:list]
       if request.xhr? 
         if @list == 'mine'
            render :partial => "mods_list", :layout => false
         else
            render :partial => "global_list", :layout => false
         end
       end
    
  end
  
  
  def create
      if request.post? and !params[:mod][:type].empty?
           @mod = create_module_object(params[:mod][:type])
           @mod.attributes = params[:mod]
           if @mod.save 
             create_and_add_resource(@user,@mod)
             redirect_to  :action => 'edit' , :id =>@mod.id, :type => @mod.class
          else
            flash[:error] = "Could not create the module. There were problems with the following fields:
                           #{@mod.errors.full_messages.join(", ")}" 
             flash[:mod_title] = params[:mod][:module_title]  
             flash[:mod_type] = params[:mod][:type] 
       
              flash[:mod_title_error] = @mod.errors[:module_title]
             flash[:mod_type_error] = @mod.errors[:type]
             redirect_to  :action => 'index', :list=> 'mine'
          end
        else
           flash[:error] = "Could not create the module. There were problems with the following fields:
                           Content Type can not be blank" 
             flash[:mod_title] = params[:mod][:module_title]  
             flash[:mod_type] = params[:mod][:type] 
              flash[:mod_title_error] = "" unless params[:mod][:module_title]  
             flash[:mod_type_error] = ""
          redirect_to  :action => 'index', :list=> 'mine'
      end
  end
  
  def new
     if request.post? 
       unless params[:type]==""
           @mod = create_module_object(params[:type])
           @mod.update_attribute(:module_title ,params[:name])
           if @mod.save 
             create_and_add_resource(@user,@mod)
             redirect_to  :action => 'edit' , :id =>@mod.id, :type => @mod.class
           else
            flash[:error] = "Could not create the module. There were problems with the following fields:
                           #{@mod.errors.full_messages.join(", ")}" 
             flash[:mod_title] = params[:name]  
             flash[:mod_type] = params[:type] 
       
              flash[:mod_title_error] = @mod.errors[:module_title] 
             flash[:mod_type_error] = @mod.errors[:type]
             redirect_to  :action => 'index', :list=> 'mine'
          end
       else
          flash[:error] = "Could not create the module. There were problems with the following fields:
                           Content Type can not be blank" 
             flash[:mod_title] = params[:name]  
             flash[:mod_type] = params[:type] 
              flash[:mod_title_error] = "" unless params[:name] 
             flash[:mod_type_error] = ""
          redirect_to  :action => 'index', :list=> 'mine'
       end
      end
  end
  


  def edit
     @ecurrent = 'current'
     begin
      @mod = find_mod(params[:id], params[:type])
     rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid module #{params[:id]}" )
      flash[:notice] = "You are trying to access a module that doesn't yet exist. Be proactive and go create it!"
      redirect_to  :action => 'index', :list=> 'mine'
    else
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
            redirect_to :action => "preview" , :id =>@mod.id, :type=> @mod.class
          end
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
      render :partial => "/module/reserved_titles", :locals => {:reserves => reserves} and return
    end
    redirect_to :action => :index
  end
  
  
  def edit_reserves
     @ecurrent = 'current'
     @title = "Edit Course Reserves"
     @subj_list = get_subject_values
     begin
      @mod = find_mod(params[:id], "ReserveResource")
     rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid module #{params[:id]}" )
      flash[:notice] = "You are trying to access a module that doesn't yet exist. Be proactive and go create it!"
      redirect_to  :action => 'index', :list=> 'mine'
    else
      unless @mod.course_title == nil
         redirect_to :action => 'save_reserves', :id => @mod.id
      end  
    end
    if request.post? and params[:page_subject] and params[:page_cnum] 
       @mod.update_attribute(:course_title,"#{params[:page_subject]} #{params[:page_cnum]}")
    
       redirect_to :action => 'save_reserves', :id => @mod.id
    end
  end
 
 
  def save_reserves
     @ecurrent = 'current'
     @title = "Edit Course Reserves"
     begin
        @mod = find_mod(params[:id], "ReserveResource")
     rescue ActiveRecord::RecordNotFound
        logger.error("Attempt to access invalid module #{params[:id]}" )
        flash[:notice] = "You are trying to access a module that doesn't yet exist."
        redirect_to  :action => 'index', :list=> 'mine'
     else
         #We need to pull the reserves available for this course when we edit it,
         #and then conditionally check the boxes in the view if that reserve is already
         #saved in the module.
         @reserves = search_reserves(@mod.course_title)
      end
      if request.post?
           @mod.attributes = params[:mod] 
           if @mod.save
              desired_reserves = []
             if params[:reserves]
               #if no box is checked in the view, no param is passed so we need to clear out the reserves
               #get the tucked away reserves from the session if our searched for
               #reserves are actually courses.  The counterpart to this is found
               #in :retrieve_reserves. 
               @reserves = session[:reserves] if @reserves.first[:course]
               @reserves.each { |r| desired_reserves << r if params[:reserves].include?(r[:id].to_s) }
               session[:reserves] = nil 
             end
             @mod.update_attribute(:library_reserves, desired_reserves)
             redirect_to :action => "preview" , :id =>@mod.id, :type=> @mod.class
         end
     end 
   end
   
   def edit_databases
     @ecurrent = 'current'
     begin
      @mod = find_mod(params[:id], "DatabaseResource")
     rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid module #{params[:id]}" )
      flash[:notice] = "You are trying to access a module that doesn't yet exist. Be proactive and go create it!"
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
      flash[:notice] = "You are trying to access a module that doesn't yet exist. Be proactive and go create it!"
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
      redirect_to :action => "preview" , :id =>@mod.id, :type=> @mod.class
    end
  end
  
 
  
   # Makes a new copy of a module and add it to the user
  def copy
    begin
     @old_mod = find_mod(params[:id],params[:type])
    rescue Exception => e
     logger.error("Exception in add_copy: #{e}")
     flash[:notice] = "You are trying to access a module that doesn't yet exist. Be proactive and go create it!"
     redirect_to :action => 'index', :list=> 'mine'
   else
    if @old_mod.class == DatabaseResource
        redirect_to :action => 'copy_databases', :id => @old_mod.id, :type => @old_mod.class
    end
      @mod = @old_mod.clone
      @mod.label = @old_mod.module_title+"-copy"
     
    end  
     if request.post?
       @mod.attributes = params[:mod]
       @mod.update_attributes(:global => false)
       if @mod.save
          create_and_add_resource(@user,@mod)
          redirect_to :action => "preview", :id =>@mod.id, :type =>@mod.class
       end
     end
 end  
 
  def copy_databases
    begin
     @old_mod = find_mod(params[:id],params[:type])
    rescue Exception => e
     logger.error("Exception in add_copy: #{e}")
     flash[:notice] = "You are trying to access a module that doesn't yet exist. Be proactive and go create it!"
     redirect_to :action => 'index', :list=> 'mine'
   else
      @mod = @old_mod.clone
      @mod.module_title = @old_mod.module_title+"-copy"
      @old_mod.database_dods.each do |db|
        clone_db = db.clone
        @mod.database_dods << clone_db
      end 
    if @mod.save  
       create_and_add_resource(@user,@mod)
      redirect_to  :action => 'edit_databases', :id =>@mod.id, :type=> @mod.class
    end
   end  
  end
  
 def copy_global
    begin
     @mod = find_mod(params[:id],params[:type])
    rescue Exception => e
     logger.error("Exception in add_copy: #{e}")
     flash[:notice] = "You are trying to access a module that doesn't yet exist. Be proactive and go create it!"
      redirect_to :action => 'index', :list =>'global'
    else
       @mod_copy = @mod.clone
       @mod_copy.update_attributes(:global => false)
       if @mod_copy.save
          create_and_add_resource(@user,@mod_copy)
          if request.xhr?
            render :partial => 'notice', :layout => false
          else
             redirect_to :action => 'index', :list => 'mine'
          end
       end
   end
 end
    
 def add_to_page
   session[:page_list] = []
   begin
     @mod = find_mod(params[:id],params[:type])
   rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid module" )
      flash[:notice] = "You are trying to access a module that doesn't yet exist."
      redirect_to  :action => 'index', :list=> 'mine'
    else
        resource = @user.find_resource(params[:id],params[:type])
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
        page = (params[:page] ||= 1).to_i
        items_per_page = 15
        offset = (page - 1) * items_per_page       
       @pages = @user.pages.find(:all, :order => sort)
        #create a Paginator
           @which_pages = Paginator.new(self, @pages.length, items_per_page, page)          
       #only send a subset of @pages to the view
           @pages = @pages[offset..(offset + items_per_page - 1)]
       if request.xhr?
           render :partial => "add_page_list", :layout => false
       elsif request.post?
         params[:page_list].each do |pid|
           page = @user.pages.find_by_id(pid)
           page.add_resource(resource)
         end
         session[:page_list] += params[:page_list]
         redirect_to :action => "add_page_success", :id =>@mod.id, :type=> @mod.class
      end
    end
 end
 
 def add_page_success
   @pages = []
    begin
     @mod = find_mod(params[:id],params[:type])
    rescue Exception => e
     logger.error("Exception in add_copy: #{e}")
     flash[:notice] = "You are trying to access a module that doesn't yet exist. "
      redirect_to :action => 'index', :list=> 'mine'
    else
      flash.now[:message] = "#{@mod.module_title} successfully added to these pages."
      session[:page_list].each do |pid|
         @pages << @user.pages.find_by_id(pid)
     end
   end 
 end
 
 def add_to_guide
    session[:guide_list] =[]
    begin
     @mod = find_mod(params[:id],params[:type])
   rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid module" )
      flash[:notice] = "You are trying to access a module that doesn't yet exist."
      redirect_to  :action => 'index', :list=> 'mine'
    else
     resource = @user.find_resource(params[:id],params[:type])
     sort = case params['sort']
             when "name"  then "guide_name"
             when "date"   then "updated_at"
             when "publish" then "published, guide_name"
             when "archive"  then "archived, guide_name"
             when "name_reverse"  then "guide_name DESC"
             when "date_reverse"   then "updated_at DESC, guide_name"
             when "publish_reverse" then "published DESC, guide_name"
             when "archive_reverse"  then "archived DESC, guide_name"
             when " " then "guide_name"
           end
   #read and set the variables 
       page = (params[:page] ||= 1).to_i
       items_per_page = 15
       offset = (page - 1) * items_per_page
   #get the user's pages
       @guides = @user.guides.find(:all, :order => sort)
   #create a Paginator
       @which_pages = Paginator.new(self, @guides.length, items_per_page, page)          
   #only send a subset of @pages to the view
       @guides = @guides[offset..(offset + items_per_page - 1)]
   end  
   if request.xhr?
       render :partial => "add_guide_list", :layout => false
   elsif request.post?
       params[:tab_list].each do |tid|
         tab = Tab.find(tid)
         tab.add_resource(resource)
         session[:guide_list] << tab.guide_id
       end
       redirect_to :action => "add_guide_success", :id =>@mod.id, :type=> @mod.class
    end
 end
 
 def add_guide_success
   @guides = []
    begin
     @mod = find_mod(params[:id],params[:type])
    rescue Exception => e
     logger.error("Exception in add_copy: #{e}")
     flash[:notice] = "You are trying to access a module that doesn't yet exist. "
      redirect_to :action => 'index', :list=> 'mine'
    else
      flash.now[:message] = "#{@mod.module_title} successfully added to these guides."
      session[:guide_list].each do |gid|
         @guides << @user.guides.find(gid)
     end
   end 
 end
 
 def unglobalize 
   begin
     @mod = find_mod(params[:id],params[:type])
    rescue Exception => e
     logger.error("Exception in add_copy: #{e}")
     flash[:notice] = "You are trying to access a module that doesn't yet exist. "
      redirect_to :action => 'index', :list=> 'mine'
    else
       @mod.update_attribute(:global, 0)
       redirect_to :back, :page => params[:page]
    end   
 end
 
 def globalize 
   begin
     @mod = find_mod(params[:id],params[:type])
    rescue Exception => e
     logger.error("Exception in add_copy: #{e}")
     flash[:notice] = "You are trying to access a module that doesn't yet exist. "
      redirect_to :action => 'index', :list=> 'mine'
    else
       @mod.update_attribute(:global, 1)
       redirect_to :back, :page => params[:page]
    end
 end
 

  def share
  begin
     @mod = find_mod(params[:id],params[:type])
  rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid module #{params[:id]}" )
      flash[:notice] = "You are trying to access a module that doesn't yet exist"
      redirect_to :action => 'index', :list=> 'mine'
  else
    resource = @user.find_resource(params[:id],params[:type])
    @user_list = User.find(:all, :order => "name")
    @mod_owners = resource.users
  end
  
    if request.post? 
      if params[:users]
        params[:users].each do |p|
          new_user = User.find(p)
          if new_user and @mod_owners.include?(new_user)== false
             new_user.add_resource(resource)
            begin
              Notifications.deliver_share_module(new_user.email,@user.email,@mod.module_title)
            rescue Exception => e
              logger.error("Exception in share module: #{e}}" )
              flash[:notice] = "Could not send email"
              redirect_to  :action => "share",:id =>@mod.id, :type=> @mod.class and return
            end
         end
       end
        flash[:notice] = "User(s) successfully added."
       redirect_to :action => 'share',:id =>@mod.id, :type=> @mod.class
      else
        flash[:notice] = "Please select at least one user to share with."
        redirect_to :action => 'share',:id =>@mod.id, :type=> @mod.class
      end
    end
end

  def remove_user_from_mod
    begin
     resource = @user.find_resource(params[:id],params[:type] )
    rescue Exception => e
     logger.error("Exception in remove_from_user: #{e}" )
     flash[:notice] = "You are trying to access a module that doesn't yet exist. "
     redirect_to :action => 'index', :list=> 'mine'
    else
    user = resource.users.find_by_id(params[:user])
    resource.users.delete(user)
    redirect_to :action => 'share', :id => resource.mod.id, :type =>resource.mod.class
    end
  end
 
 

  def preview
     @pcurrent = 'current'
    begin
      @mod = find_mod(params[:id],params[:type] )
    rescue Exception => e
      logger.error("Exception in show: #{e}" )
      flash[:notice] = "You are trying to access a module that doesn't yet exist. "
      redirect_to :action => 'index', :list=> 'mine'
     end
  end
  
  def preview_global
    begin
      @mod = find_mod(params[:id],params[:type] )
    rescue Exception => e
      logger.error("Exception in show: #{e}" )
      flash[:notice] = "You are trying to access a module that doesn't yet exist. "
      redirect_to :back
    else
      @title = "Previewing Module #{@mod.module_title}"
    end
  end

 
 
 #removes a  module from a user through resources
  def remove_from_user
    begin
     resource = @user.find_resource(params[:id],params[:type] )
    rescue Exception => e
     logger.error("Exception in remove_from_user: #{e}" )
     flash[:notice] = "You are trying to access a module that doesn't yet exist. "
     redirect_to :action => 'index', :list=> 'mine'
   else
     @user.rid = nil if @user.rid == resource.id
     unless resource.users.length > 2 #only 1 owner so delete all associations
       resource.delete_mods
       @user.resources.delete(resource)
       resource.destroy
     else # else just delete this users tie 
       @user.resources.delete(resource)
     end
     redirect_to :action => 'index', :list => 'mine', :sort =>'name', :page => params[:page]
    end
  end

def more_info
    begin
     @mod = find_mod(params[:id],"MiscellaneousResource")
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid page #{params[object_id]}" )
      render :status => 404,
      :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
      :layout => false 
    end
 end
 
private
 
  
 def select_layout
   if ['index'].include?(action_name) 
     "dashboard" 
   elsif ['preview_global'].include?(action_name)
     "popup"
   elsif  ['more_info'].include?(action_name)
      "popup"   
   else 
     "overview"
   end
 end
 
 
end
