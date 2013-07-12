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
end
