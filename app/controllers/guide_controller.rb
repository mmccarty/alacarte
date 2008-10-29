class GuideController < ApplicationController
include ReservesScraper
before_filter :authorize
before_filter :current_guide, :only =>[:remove_user_from_guide, :toggle_columns, :create_tab, :edit_tab, :show_tab, :delete_tab, :add_modules, :new_module, :edit_module, :update_module, :view_mod,:remove_module, :edit_reserves, :save_reserves, :retrieve_reserves, :edit_databases, :update_databases, :add_databases]
before_filter :current_tab, :only =>[:edit_reserves, :save_reserves, :retrieve_reserves, :update_databases, :add_databases,:add_modules, :new_module, :edit_module, :update_module, :remove_module, :sort, :toggle_columns]
before_filter :module_types, :only =>[ :add_modules]
before_filter :altered_guides, :except => [:index, :create, :sort, :retrieve_reserves, :destroy ]
before_filter :clear_tab_sessions, :except=>[:share, :update, :toggle_columns, :edit, :done_editing, :add_modules, :new_module, :edit_module, :update_module, :remove_module, :view_mod, :edit_reserves, :save_reserves, :retrieve_reserves, :edit_databases, :update_databases, :add_databases, :sort]
in_place_edit_for :tab, :tab_name 
layout :select_layout


 #list of guides, expects a sort value.has an ajax component to handle the sorting
 def index
   @gcurrent = 'current'
   @subjects = get_subject_values
   @guide_types = get_guide_types
 
   sort = case params['sort']
             when "name"  then "guide_name"
             when "date"   then "updated_at"
             when "publish" then "published, guide_name"
             when "archive"  then "archived, guide_name"
             when "name_reverse"  then "guide_name DESC"
             when "date_reverse"   then "updated_at DESC, guide_name"
             when "publish_reverse" then "published DESC, guide_name"
             when "archive_reverse"  then "archived DESC, guide_name"
             else "guide_name"
           end
   #read and set the variables 
       @page = (params[:page] ||= 1).to_i
       items_per_page = 15
       offset = (@page - 1) * items_per_page
   #get the user's pages
       @guides = @user.guides.find(:all, :order => sort.downcase)
   #create a Paginator  
       @which_pages = Paginator.new(self, @guides.length, items_per_page, @page)          
   #only send a subset of @pages to the view
       @guides = @guides[offset..(offset + items_per_page - 1)]
       
   if request.xhr?
      render :partial => "guides_list", :layout => false
    end
 end
 
 #create a new guide Just takes the title fields to pass validation it is then passed to update for the rest of the fields
 def create
      if request.post?
        @guide =  Guide.new
        @guide.attributes = params[:guide]
        @guide.created_by = @user.name
        @guide.resource_id = @user.rid  unless @user.rid.blank?
        if @guide.save 
           session[:guide] = @guide.id
           session[:current_tab] = @guide.tabs.find(:first)
           @user.add_guide(@guide)
           redirect_to  :action => 'update', :id => @guide.id
         else
          flash[:error] = "Could not create the guide. There were problems with the following fields:
                           #{@guide.errors.full_messages.join(", ")}" 
        
          flash[:guide_title] = params[:guide][:guide_title]  
          flash[:guide_title_error] = @guide.errors[:guide_title]
          redirect_to :action => 'index', :sort =>"name"
       end
     end  
 end
 
 #update a guides title, add associations to link guides to the master subject and course pages. Also add metadata about the guide.
  def update
     @ucurrent = 'current'
     @subjects = get_subject_values
     @guide_types = get_guide_types
     @resources = @user.contact_resources
    begin
      @guide =  @user.guides.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid guide #{params[:id]}" )
      flash[:notice] = "You are tring to access something that either doesn't exist or you don't have access to."
      redirect_to  :action => 'index'
    else
     @selected_types = []
     @guide.masters.each do |type|
        @selected_types << type.id 
      end
      @selected_subjs = []
        @guide.subjects.each do |subj|
           @selected_subjs << subj.id 
         end
       @selected = @guide.resource_id
      if request.post?
         @guide.attributes = params[:guide]
         @guide.add_master_type(params[:types]) 
         @guide.add_related_subjects(params[:subjects])
         @guide.add_contact_module(params[:contact])
         @guide.add_tags(params[:tags])
         
         if @guide.save
           redirect_to :action => 'edit', :id => @guide.id
         end
      end
    end
  end

#edit the guides tabs and modules. default shows first tab unless params[tab] is set
  def edit
     @ecurrent = 'current'
    begin
      @guide = @user.guides.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid guide #{params[:id]}" )
      flash[:notice] = "You are tring to access something that either doesn't exist or you don't have access to."
      redirect_to  :action => 'index'
    else
      session[:guide] = @guide.id
      @tabs = @guide.tabs
     unless params[:tab]
         @tab = @tabs.find(:first)
      else
         @tab = @tabs.find(params[:tab])
      end  
      if @tab.template ==2
        @mods_left  = @tab.odd_modules
        @mods_right = @tab.even_modules
      else
        @mods = @tab.tab_resources
      end
      session[:current_tab] = @tab.id
    end  
  end
  
#Sort function for drag and drop  
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
   render :nothing => true 
end

 #share a guide with other users and remove users from a guide 
  def share
   begin
      @guide = @user.guides.find(params[:id])
  rescue ActiveRecord::RecordNotFound
      logger.error("You are tring to access something that either doesn't exist or you don't have access to. #{params[:id]}" )
      flash[:notice] = "You are tring to access something that either doesn't exist or you don't have access to."
      redirect_to :action => 'index'
  else
    session[:guide] = @guide.id
    @user_list = User.find(:all, :order => "name")
    @guide_owners = @guide.users
  end
  
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
              redirect_to  :action => "share" and return 
            end
         end
       end
          flash[:notice] = "User(s) successfully added."
          redirect_to :action => 'share', :id =>@guide.id
      else
        flash[:notice] = "Please select at least one user to share with."
        redirect_to :action => 'share', :id => @guide.id
      end
    end
  end
 
  #remove a user from the list of editors via share page
  def remove_user_from_guide
    begin
    user = @guide.users.find_by_id(params[:id])
    rescue Exception => e
     logger.error("Exception in remove_from_user: #{e}" )
     flash[:notice] = "You are trying to access a guide that doesn't yet exist. "
     redirect_to :action => 'index', :list=> 'mine'
    else
    @guide.users.delete(user)
    redirect_to :action => 'share', :id => @guide
    end  
  end
  
  #delete the guide from a user. if only one user then deletes the guide else removes the assocations.
  def destroy
      begin
      guide = @user.guides.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access You are tring to access something that either doesn't exist or you don't have access to. #{params[:id]}" )
      flash[:notice] = "You are tring to access something that either doesn't exist or you don't have access to."
      redirect_to :action => 'index'
    else
    if guide.users.length == 1 # if only one owner delete the guide
       @user.guides.delete(guide)
       guide.destroy
    else # just delete the association
         @user.guides.delete(guide)
    end  
    redirect_to :action => 'index', :sort=> "name", :page => params[:page]
    end
  end
  
  #publish the guide to the guide portal page
  def publish
    begin
      @guide = @user.guides.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      logger.error("You are tring to access something that either doesn't exist or you don't have access to. #{params[:id]}" )
      flash[:notice] = "You are tring to access something that either doesn't exist or you don't have access to."
      redirect_to :action => 'index'
    else
      if @guide.resource || @guide.published?
         @guide.toggle!(:published)
         redirect_to :back
      else
          flash[:error] = "A contact module is required before you can publish the guide."
           flash[:contact_error] = ""
          redirect_to  :action => 'update', :id => @guide
      end
     end
  end
  
  #controls the list of recent edits. allows usres to remove guides from the list.
   def done_editing
    if request.post? and params[:altered_list]
      params[:altered_list].each do |gid|
          session[:guide_list].delete(gid.to_i)
          break
      end
      if session[:guide_list].empty?
         session[:guide_list] = nil
         redirect_to :action => 'index', :sort =>"name"
      else
        begin
          guide = @user.guides.find(session[:guide_list].at(0))
        rescue ActiveRecord::RecordNotFound
          session[:guide_list] = nil
         redirect_to :action => 'index', :sort =>"name"
        else
          redirect_to :action => 'edit' ,:id => guide, :sort =>'name'
        end
      end
    else
       redirect_to :back
    end
     
 end
 
 #create a new tab
  def create_tab
     if request.post?
       if @guide.reached_limit?
          flash[:error] = "Could not create the tab. This guide has reached the 6 tab limit" 
          redirect_to :action => 'edit', :id => @guide
       else
          tab =  Tab.new
          tab.attributes = params[:tab]
          if tab.save
            @guide.add_tab(tab)
            session[:current_tab] = tab.id
            redirect_to :action => 'show_tab', :id => tab.id
          else
           redirect_to :action => 'edit', :id => @guide
          end
       end
     end
  end
  
  #show the selected tab. uses ajax to update the tab.
  def show_tab
    @ecurrent = 'current'
    begin
     @tab  = @guide.tabs.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      logger.error("You are tring to access something that either doesn't exist or you don't have access to. #{params[:id]}" )
      flash[:notice] = "You are tring to access something that either doesn't exist or you don't have access to."
      redirect_to :action => 'index'
    else 
      session[:current_tab] = @tab.id
      @tabs = @guide.tabs
      if @tab.template ==2
        @mods_left  = @tab.odd_modules
        @mods_right = @tab.even_modules
      else
        @mods = @tab.tab_resources
      end
    end
    if request.xhr?
      render :partial => 'edit_tab', :layout => false
    else
      render :action => 'edit', :id => @guide
    end
  end
 
  
  def delete_tab
    unless @guide.tabs.length == 1
      begin
       tab  = @guide.tabs.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        logger.error("You are tring to access something that either doesn't exist or you don't have access to. #{params[:id]}" )
        flash[:notice] = "You are tring to access something that either doesn't exist or you don't have access to."
        redirect_to :action => 'index'
      else 
      @guide.tabs.delete(tab)
      tab.destroy
      end
    else
      flash[:error] = "Can not delete the tab. A guide must have at least one tab." 
    end  
    
    redirect_to :action => 'edit', :id => @guide
  end
  
   def add_modules
     @amcurrent = 'current'
     @mods = sorted_mods(params['sort'])
     #read and set the variables 
       page = (params[:page] ||= 1).to_i
       items_per_page = 15
       offset = (page - 1) * items_per_page
      #create a Paginator
       @which_mods = Paginator.new(self, @mods.length, items_per_page, page)          
      #only send a subset of @pages to the view
       @mods = @mods[offset..(offset + items_per_page - 1)]        
       if request.xhr? 
          render :partial => "shared/add_modules_list", :layout => false
       elsif request.post?
         @tab.update_resource(params[:mod_list], @user.resources) 
         redirect_to :action => "show_tab", :id => @tab.id
      end
  end 


    def new_module
       unless params[:mod][:type].empty? 
           @mod = create_module_object(params[:mod][:type])
           @mod.attributes = params[:mod]
           if @mod.save 
             create_and_add_resource(@user,@mod,nil,@tab)
             redirect_to  :action => 'edit_module' , :id =>@mod.id, :type => @mod.class
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
    
  def edit_module
    @ecurrent = 'current'
    begin
      @mod ||= find_mod(params[:id], params[:type])
     rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid module #{params[:id]}" )
      flash[:notice] = "You are trying to access a module that doesn't yet exist."
      redirect_to  :action => 'index' and return
    else
       if @mod.class.to_s == "ReserveResource"
           redirect_to :action => 'edit_reserves', :id => @mod.id and return
        end
        if @mod.class.to_s == "DatabaseResource"
          redirect_to  :action => 'edit_databases', :id => @mod.id and return
        end
    end
end

def update_module
  @mod ||= find_mod(params[:id], params[:type])
  @mod.attributes = params[:mod] 
      if @mod.save
         if params[:comment_ids]
             Comment.delete(params[:comment_ids])
         end
         if params[:more]== 1
             @mod.update_attribute(:more_info, nil)
         end
         if params[:targets]
             @mod.add_lf_targets(params[:targets])
         end
         redirect_to :action => "show_tab", :id => @tab.id
      end
end    
 #removes a module from a tab.
  def remove_module
    begin
     resource = @tab.find_resource(params[:id],params[:type] )
     rescue ActiveRecord::RecordNotFound
        logger.error("You are tring to access something that either doesn't exist or you don't have access to. #{params[:id]}" )
        flash[:notice] = "You are tring to access something that either doesn't exist or you don't have access to."
        redirect_to :action => 'index'
      else 
     @tab.resources.delete(resource)
      redirect_to :action => "show_tab", :id => @tab.id
     end
  end
  
  def add_databases
   @mod = find_mod(params[:id], "DatabaseResource")
   if request.xhr?
     unless session[:selected].include?(params[:cid].to_s)
        session[:selected] << params[:cid]
     end
     render :nothing => true, :layout => false
   elsif request.post? and !session[:selected].blank?
        session[:selected].each do |db|
          dod = Dod.find(db)
          @mod.add_dod(dod)
        end 
        session[:selected] = nil if session[:selected]
        redirect_to  :action => 'edit_databases', :id =>@mod.id
    else
     redirect_to  :action => 'edit_databases', :id =>@mod.id
   end
  end
  
  def edit_databases
     @ecurrent = 'current'
     begin
        @mod = find_mod(params[:id], "DatabaseResource")
        session[:selected] ||= Array.new 
     rescue ActiveRecord::RecordNotFound
        logger.error("Attempt to access invalid module #{params[:id]}" )
        flash[:notice] = "You are trying to access a module that doesn't yet exist. "
        redirect_to  :action => 'index', :list=> 'mine'
     else
       @letter = params[:sort] ? params[:sort] : "A" 
       @dbs = Dod.sort(@letter)
   end
   if request.xhr?
        render :partial => "shared/a_z_list", :layout => false
    end
  end
  
 def update_databases
    @mod = find_mod(params[:id], "DatabaseResource")
    if request.post?
        @mod.update_attributes( params[:mod]) 
        @mod.database_dods.each { |t| t.attributes = params[:database_dod][t.id.to_s] } 
        @mod.database_dods.each(&:save!)
        if params[:db_remove_list]
          params[:db_remove_list].each do |did|
             dod = @mod.dods.find(did)
             @mod.dods.delete(dod) if dod
          end   
        end
        session[:selected] = nil if session[:selected]
        redirect_to :action => "show_tab", :id => @tab.id 
    end
 end
 
   #sets the template 
  def toggle_columns
   if @tab.template == 2
      @tab.update_attribute(:template, 1)
   else
      @tab.update_attribute(:template, 2)
   end
   redirect_to :action => "edit" , :id => @guide, :tab => @tab
 end
  
  
  
 private
  
  def select_layout
   if ['index'].include?(action_name) 
     "dashboard" 
   elsif ['view_mod'].include?(action_name)
     "popup"
   else 
     "overview"
   end
  end
  
end
