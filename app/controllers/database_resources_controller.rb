class DatabaseResourcesController < ApplicationController
  before_filter :module_types
  before_filter :current_page
  before_filter :current_guide
  before_filter :current_tutorial
  layout 'admin'

  def show
    @mod = DatabaseResource.find params[:id]
  end

  def edit
    @mod = DatabaseResource.find params[:id]
  end

  def update
    @mod = DatabaseResource.find params[:id]
    @mod.update_attributes params[:mod]
    if @mod.save
      redirect_to @mod
    else
      render :edit
    end
  end

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
