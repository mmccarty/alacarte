class UploaderController < ApplicationController
  before_filter :module_types
  before_filter :current_page
  before_filter :current_guide
  before_filter :current_tutorial
  layout 'tool'

  def edit_uploader
    @ecurrent = 'current'
    begin
      @mod = find_mod(params[:id], "UploaderResource")
    rescue ActiveRecord::RecordNotFound
      redirect_to :controller => 'module', :action => 'index', :list=> 'mine'
    else
      @tags = @mod.tag_list
      session[:mod_id] = @mod.id
      session[:mod_type] = @mod.class
    end
  end

  def update_uploader
    params[:mod][:existing_uploadable_attributes] ||= {}
    params[:mod][:new_uploadable_attributes] ||= {}
    @mod = find_mod(params[:id], "UploaderResource")
    if @mod.update_attributes(params[:mod])
      @mod.add_tags(params[:tags]) if params[:tags]
      redirect_to :controller => 'module', :action => "preview" , :id =>@mod.id, :type=> @mod.class
    else
      render :action => 'edit_uploader' , :mod => @mod
    end
  end

  def copy_uploader
    begin
      @old_mod = find_mod(params[:id], "UploaderResource")
    rescue Exception
      redirect_to :controller => 'module', :action => 'index', :list=> 'mine'
    else
      @mod = @old_mod.clone
      @mod.global = false
      @mod.label =  @old_mod.label+'-copy'
      if @mod.save
        @mod.uploadables << @old_mod.uploadables
        create_and_add_resource(@user,@mod)
        flash[:notice] = "Saved as #{@mod.label}"
        redirect_to  :controller => 'module', :action => "edit_content" , :id =>@mod.id, :type=> @mod.class
      end
    end
  end
end
