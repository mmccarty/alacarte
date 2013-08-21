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
    @mod.update_attributes params[:lib_resource]
    if @mod.save
      redirect_to @mod
    else
      render :edit
    end
  end
end
