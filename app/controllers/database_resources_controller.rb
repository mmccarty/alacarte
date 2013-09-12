class DatabaseResourcesController < ApplicationController
  before_filter :module_types
  layout 'admin'

  def show
    @mod = DatabaseResource.find params[:id]
  end

  def edit
    @mod = DatabaseResource.find params[:id]
  end

  def update
    @mod = DatabaseResource.find params[:id]
    @mod.update_attributes database_resource_params
    if @mod.save
      redirect_to @mod
    else
      render :edit
    end
  end

  def copy
    old_mod = DatabaseResource.find params[:id]
    @new_mod = old_mod.dup
    if @new_mod.save
      create_and_add_resource @user, @new_mod
      redirect_to edit_database_resource_path(@new_mod)
    end
  end

  def add_databases
    @mod ||= find_mod params[:id], 'DatabaseResource'
    if request.xhr?
      unless session[:selected].include?(params[:cid].to_s)
        session[:selected] << params[:cid]
      end
      render :nothing => true, :layout => false
    elsif request.get?
      session[:selected] = []
      @dods = Dod.all
      render :add_databases
    elsif request.post? and !session[:selected].blank?
      session[:selected].each do |db|
        dod = Dod.find db
        @mod.add_dod dod
      end
      session[:selected] = nil if session[:selected]
      redirect_to polymorphic_path @mod, action: :edit
    else
      redirect_to polymorphic_path @mod, action: :edit
    end
  end

  def remove_database
    begin
      @mod = find_mod params[:id], 'DatabaseResource'
      database_dod = @mod.database_dods.find_by_dod_id params[:dod_id]
      database_dod.destroy
      redirect_to :back
    rescue ActiveRecord::RecordNotFound
      redirect_to :back and return
    end
  end

  private

  def database_resource_params
    params.require(:database_resource).permit :module_title
  end
end
