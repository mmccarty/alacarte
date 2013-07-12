class UrlResourcesController < ApplicationController
  before_filter :module_types
  before_filter :current_page
  before_filter :current_guide
  before_filter :current_tutorial
  layout 'admin'

  def show
    @mod = UrlResource.find params[:id]
  end

  def edit
    @mod = UrlResource.find params[:id]
  end

  def update
    @mod = UrlResource.find params[:id]
    @mod.update_attributes params[:mod]
    if @mod.save
      redirect_to @mod
    else
      render :edit
    end
  end

  def copy_url
    begin
      @old_mod = find_mod(params[:id], "UrlResource")
    rescue Exception
      redirect_to :controller => 'module', :action => 'index', :list=> 'mine'
    else
      @mod = @old_mod.clone
      @mod.global = false
      @mod.label =  @old_mod.label+'-copy'
      if @mod.save
        @mod.links << @old_mod.links.collect{|l| l.clone if l}
        create_and_add_resource(@user,@mod)
        flash[:notice] = "Saved as #{@mod.label}"
        redirect_to  :controller => 'module', :action => "edit_content" , :id =>@mod.id, :type=> @mod.class
      end
    end
  end

  #Sort modules function for drag and drop
  def sort
    if params['links'] then
      sortables = params['links']
      sortables.each do |id|
        link = Link.find(id)
        link.update_attribute(:position, sortables.index(id) + 1 )
      end
    end
    render :nothing => true
  end
end
