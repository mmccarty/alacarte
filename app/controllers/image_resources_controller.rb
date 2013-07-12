class ImageResourcesController < ApplicationController
  before_filter :module_types
  before_filter :current_page
  before_filter :current_guide
  before_filter :current_tutorial
  layout 'admin'

  def show
    @mod = ImageResource.find params[:id]
  end

  def edit
    @mod = ImageResource.find params[:id]
  end

  def update
    @mod = ImageResource.find params[:id]
    @mod.update_attributes params[:mod]
    if @mod.save
      redirect_to @mod
    else
      render :edit
    end
  end

  def search_flickr
    @mod = find_mod(params[:id], "ImageResource")
    @query = params[:search_value]
    session[:search_result] = @query
    flickr = Flickr.new("#{Rails.root}/config/flickr.yml")
    begin
      @list = flickr.photos.search(:text => @query.gsub(/ /,'') , 'per_page' => 8, 'page' => 1, :media => 'photos')
    rescue  Exception
      @list = ""
    end
    render :partial => "image/search_results", :locals => {:list => @list, :mod =>@mod} and return
  end

  def save_image
    session[:search_result] = nil
    @mod = find_mod(params[:id], "ImageResource")
    @url = params[:url]
    new = Image.new(:url => params[:url], :alt =>params[:alt], :description => params[:description])
    @mod.images << new
    render :partial => "image/image", :collection => @mod.images, :locals => {:mod =>@mod} and return
  end

  def copy_image
    begin
      @old_mod = find_mod(params[:id], "ImageResource")
    rescue Exception
      redirect_to :controller => 'module', :action => 'index', :list=> 'mine'
    else
      @mod = @old_mod.clone
      @mod.global = false
      @mod.label =  @old_mod.label+'-copy'
      if @mod.save
        @mod.images << @old_mod.images.collect{|v| v.clone if v}
        create_and_add_resource(@user,@mod)
        flash[:notice] = "Saved as #{@mod.label}"
        redirect_to  :controller => 'module', :action => "edit_content" , :id =>@mod.id, :type=> @mod.class
      end
    end
  end
end
