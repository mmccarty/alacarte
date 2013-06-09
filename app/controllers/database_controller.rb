class DatabaseController < ApplicationController
  before_filter :module_types
  before_filter :current_page
  before_filter :current_guide
  before_filter :current_tutorial
  layout 'tool'
 
 def add_databases
   @mod ||= find_mod(params[:id], "DatabaseResource")
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
        @mod ||= find_mod(params[:id], "DatabaseResource")
     rescue ActiveRecord::RecordNotFound
        flash[:notice] = "The module doesn't exist. "
        redirect_to  :back
     else
       session[:selected] ||= Array.new 
       @letter = params[:sort] ? params[:sort] : "A" 
       @dbs = Dod.sort(@letter)
       @tags = @mod.tag_list
   end
   if request.xhr?
        render :partial => "a_z_list", :layout => false
    end
  end 
  
  #Save a database module. 
 def update_databases
    @mod ||= find_mod(params[:id], "DatabaseResource")
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
         @mod.add_tags(params[:tags]) if params[:tags]
        session[:selected] = nil if session[:selected]
        redirect_to :controller => 'module', :action => "preview" , :id =>@mod.id, :type=> @mod.class
    end
 end
 
 def copy_databases
    begin
     @old_mod = find_mod(params[:id], "DatabaseResource")
    rescue ActiveRecord::RecordNotFound
     flash[:notice] = "The module doesn't exist. "
     redirect_to :back
   else
      @mod = @old_mod.clone
      @mod.global = false
      @mod.label =  @old_mod.label+'-copy'
      if @mod.save
        @mod.database_dods << @old_mod.database_dods.collect{|d| d.clone}.flatten
        create_and_add_resource(@user,@mod)
        flash[:notice] = "Saved as #{@mod.label}"
        redirect_to  :controller => 'module', :action => "edit_content" , :id =>@mod.id, :type=> @mod.class
      end  
   end  
 end
 
 end 