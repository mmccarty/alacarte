class RssResourcesController < ApplicationController
  before_filter :module_types
  layout 'admin'

  def show
    @mod = RssResource.find params[:id]
  end

  def edit
    @mod = RssResource.find params[:id]
  end

  def update
    @mod = RssResource.find params[:id]
    @mod.update_attributes params[:rss_resource]
    if @mod.save
      redirect_to @mod
    else
      render :edit
    end
  end

  def copy
    old_mod = RssResource.find params[:id]
    @new_mod = old_mod.dup
    if @new_mod.save
      create_and_add_resource @user, @new_mod
      redirect_to edit_rss_resource_path @new_mod
    end
  end
end
