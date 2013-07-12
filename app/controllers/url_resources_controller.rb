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

  def copy
    old_mod = UrlResource.find params[:id]
    new_mod = old_mod.copy
    if new_mod.save
      create_and_add_resource @user, new_mod
      redirect_to edit_url_resource_path(new_mod)
    end
  end
end
