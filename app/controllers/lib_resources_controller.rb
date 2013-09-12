class LibResourcesController < ApplicationController
  layout 'admin'

  def show
    @mod = LibResource.find params[:id]
  end

  def edit
    @mod = LibResource.find params[:id]
  end

  def update
    @mod = LibResource.find params[:id]
    @mod.update_attributes lib_resource_params
    if @mod.save
      redirect_to @mod
    else
      render :edit
    end
  end

  private

  def lib_resource_params
    params.require(:lib_resource).permit :email
  end
end
