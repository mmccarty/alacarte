class UploaderController < ApplicationController
  before_filter :module_types
  before_filter :current_page
  before_filter :current_guide
  layout 'admin'

  def show
    @mod = UploaderResource.find params[:id]
  end

  def edit
    @mod = UploaderResource.find params[:id]
  end

  def update
    @mod = UploaderResource.find params[:id]
    @mod.update_attributes params[:mod]
    if @mod.save
      redirect_to @mod
    else
      render :edit
    end
  end

  def copy
    old_mod = UploaderResource.find params[:id]
    new_mod = old_mod.copy
    if new_mod.save
      create_and_add_resource @user, new_mod
      redirect_to edit_uploader_resource_path(new_mod)
    end
  end
end
