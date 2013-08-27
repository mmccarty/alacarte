class UrlResourcesController < ApplicationController
  before_filter :module_types
  layout 'admin'

  def show
    @mod = UrlResource.find params[:id]
  end

  def edit
    @mod = UrlResource.find params[:id]
    @link = Link.new
  end

  def update
    @mod = UrlResource.find params[:id]
    @mod.update_attributes params[:url_resource]
    if @mod.save
      redirect_to @mod
    else
      render :edit, id: @mod.id
    end
  end

  def copy
    old_mod = UrlResource.find params[:id]
    @new_mod = old_mod.dup
    if @new_mod.save
      create_and_add_resource @user, @new_mod
      redirect_to edit_url_resource_path @new_mod
    end
  end
end
