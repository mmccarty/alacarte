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
end
