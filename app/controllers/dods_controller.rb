class DodsController < ApplicationController
  before_filter :authorize_admin
  layout 'admin'

  def index
    @dods = Dod.paginate per_page: 25, page:  params[:page], order: :title
  end

  def new
    @dod = Dod.new
  end

  def create
    Dod.create dod_params
    redirect_to dods_path
  end

  def edit
    @dod = Dod.find params[:id]
  end

  def update
    dod = Dod.find params[:id]
    dod.update_attributes dod_params
    redirect_to dods_path
  end

  def destroy
    Dod.find(params[:id]).destroy
    flash[:notice] = "Dod successfully deleted."
    redirect_to dods_path
  end

  private

  def dod_params
    params.require(:dod).permit :title, :url, :provider, :descr
  end
end
