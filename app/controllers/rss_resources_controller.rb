class RssResourcesController < ApplicationController
  before_filter :module_types
  before_filter :current_page
  before_filter :current_guide
  before_filter :current_tutorial
  layout 'admin'

  def show
    @mod = RssResource.find params[:id]
  end

  def edit
    @mod = RssResource.find params[:id]
  end

  def update
    @mod = RssResource.find params[:id]
    @mod.update_attributes params[:mod]
    if @mod.save
      redirect_to @mod
    else
      render :edit
    end
  end

  def copy_feeds
    begin
      @old_mod = find_mod(params[:id], "RssResource")
    rescue Exception => e
      flash[:notice] = "The module doesn't exist. "
      redirect_to :back
    else
      @mod = @old_mod.clone
      @mod.feeds << @old_mod.feeds.collect{|f| f.clone}.flatten
      @mod.global = false
      @mod.label =  @old_mod.label+'-copy'
      if @mod.save
        create_and_add_resource(@user,@mod)
        flash[:notice] = "Saved as #{@mod.label}"
        redirect_to  :controller => 'module', :action => "edit_content" , :id =>@mod.id, :type=> @mod.class
      end
    end
  end
end
