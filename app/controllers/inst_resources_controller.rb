class InstResourcesController < ApplicationController
  layout 'admin'

  def show
    @mod = InstResource.find params[:id]
  end

  def edit
    @mod = InstResource.find params[:id]
  end

  def update
    @mod = InstResource.find params[:id]
    @mod.update_attributes params[:mod]
    if @mod.save
      redirect_to @mod
    else
      render :edit
    end
  end

  def copy
    old_mod = InstResource.find params[:id]
    @new_mod = old_mod.copy
    if @new_mod.save
      create_and_add_resource @user, @new_mod
      redirect_to edit_inst_resource_path(@new_mod)
    end
  end
end
