class MastersController < ApplicationController
  before_filter :authorize_admin
  layout 'admin'

  def index
    @masters = Master.paginate per_page: 25, page: params[:page], order: :value
  end

  def new
    @master = Master.new
  end

  def create
    Master.create master_params
    redirect_to masters_path
  end

  def edit
    @master = Master.find params[:id]
  end

  def update
    master = Master.find params[:id]
    master.update_attributes master_params
    redirect_to masters_path
  end

  def destroy
    Master.find(params[:id]).destroy
    flash[:notice] = "Master successfully deleted."
    redirect_to masters_path
  end

  private

  def master_params
    params.require(:master).permit :value
  end
end
