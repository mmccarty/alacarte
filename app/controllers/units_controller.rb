class UnitsController < ApplicationController
  include Paginating
  before_filter :current_tutorial
  before_filter :current_unit , :only => [:new_module]
  before_filter :module_types, :only =>[:add_modules]
  before_filter :clear_unit, :only => 'units'
  layout 'admin'

  def remove_unit
    unit = @tutorial.units.find(params[:id])
    uz = @tutorial.unitizations.select{|u| u.unit_id == unit.id}.first
    uz.remove_from_list
    @tutorial.units.delete(unit)
    redirect_to :back
  end

  def sort
    if params['full']
      sortables = params['full']
      sortables.each do |id|
        unitz = @tutorial.unitizations.find(id)
        unitz.update_attribute(:position, sortables.index(id) + 1 )
      end
    end
    render :nothing => true
  end

  def remove_module
    unit = @tutorial.units.find(params[:id])
    resource = unit.resources.find(params[:rid])
    resable = unit.resourceables.select{|r| r.resource_id == resource.id}.first
    resable.remove_from_list
    unit.resources.delete(resource)
    redirect_to :back, :id =>unit
  end

  def sort_mods
    @tutorial.units.each do |uz|
      unit = uz.id.to_s
      if params['full'+unit] then
        sortables = params['full'+unit]
        sortables.each do |id|
          resource = uz.resourceables.find(id)
          resource.update_attribute(:position, sortables.index(id) + 1 )
        end
      end
    end
    render :nothing => true
  end

  def add_mod
    s = params[:mid1] + params[:mid2]
    unless session[:add_mods].include?(s)
      session[:add_mods] << s
    end
    render :nothing => true
  end

  def new_module
    unless params[:mod][:type].empty?
      @mod = create_module_object(params[:mod][:type])
      @mod.attributes = params[:mod]
      @mod.slug = create_slug(params[:mod][:module_title])
      if @mod.save
        create_and_add_resource(@user,@mod,@unit)
        @tutorial.update_users if @tutorial.shared?
        redirect_to  :controller => 'module',:action => 'edit_content' , :id =>@mod.id, :type => @mod.class
      else
        flash[:error] = "Could not create the module. There were problems with the following fields: #{@mod.errors.full_messages.join(", ")}"
        flash[:mod_title] = params[:mod][:module_title]
        flash[:mod_type] = params[:mod][:type]
        flash[:mod_title_error] = @mod.errors[:module_title]
        flash[:mod_type_error] = @mod.errors[:type]
        redirect_to  :back
      end
    else
      flash[:error] = "Could not create the module. There were problems with the following fields: Content Type"
      if params[:mod][:module_title].empty?
        flash[:error] =+ "and Module Name can not be blank."
      end
      flash[:mod_title] = params[:mod][:module_title]
      flash[:mod_type] = params[:mod][:type]
      flash[:mod_title_error] = "" unless params[:mod][:module_title]
      flash[:mod_type_error] = ""
      redirect_to  :back
    end
  end
end
