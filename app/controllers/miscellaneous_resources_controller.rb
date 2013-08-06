class MiscellaneousResourcesController < ApplicationController
  layout 'admin'

  def show
    @mod = MiscellaneousResource.find params[:id]
  end

  def edit
    @mod = MiscellaneousResource.find params[:id]
  end

  def update
    @mod = MiscellaneousResource.find params[:id]
    @mod.update_attributes params[:mod]
    if @mod.save
      redirect_to @mod
    else
      render :edit
    end
  end

  def copy
    old_mod = MiscellaneousResource.find params[:id]
    @new_mod = old_mod.copy
    if @new_mod.save
      create_and_add_resource @user, @new_mod
      redirect_to edit_miscellaneous_resource_path(@new_mod)
    end
  end
end
