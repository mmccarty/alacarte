class UnitsController < ApplicationController
  include Paginating
  layout 'admin'

  def index
    @tutorial = @user.tutorials.find params[:tutorial_id]
    @units = @tutorial.unitizations
  end

  def new
    @tutorial = @user.tutorials.find params[:tutorial_id]
    @unit = Unit.new
  end

  def create
    @tutorial = @user.tutorials.find params[:tutorial_id]
    if request.post?
      @unit = Unit.new unit_params
      @unit.created_by = @user.id
      if @unit.save
        @tutorial.units << @unit
        session[:unit] = @unit.id
        redirect_to edit_tutorial_unit_path(@tutorial, @unit)
      else
        flash[:error] = "Could not create the unit. There were problems with the following fields:
                           #{@unit.errors.full_messages.join(", ")}"
        flash[:unit_name] = params[:unit][:unit_name]
        flash[:unit_name_error] = ""
        redirect_to :action => 'add' and return
      end
    end
  end

  def edit
    @tutorial = @user.tutorials.find params[:tutorial_id]
    @unit = @tutorial.units.find params[:id]
    session[:unit] = @unit.id
    @mods = @unit.resourceables
  end

  def update
    @tutorial = @user.tutorials.find params[:tutorial_id]
    @unit = @tutorial.units.find params[:id]
    session[:unit] = @unit.id
    @mods = @unit.resourceables
    @unit.update_attributes unit_params
    if @unit.save
      case params[:commit]
        when "Save"
          redirect_to tutorial_units_path(@tutorial) and return
        when "Save & Add Modules"
          redirect_to add_modules_tutorial_unit_path(@tutorial, @unit) and return
      end
    end
    render :edit
  end

  def add_modules
    @tutorial = @user.tutorials.find params[:tutorial_id]
    setSessionGuideId
    @unit ||= Unit.find(params[:id])
    session[:unit] = @unit.id
    @sort = params[:sort] || 'label'
    session[:add_mods] ||= []
    @mods = @user.sort_mods(@sort)
    @mods = paginate_mods(@mods, params[:page] ||= 1, @sort)
    @search_value = "Search My Modules"
    if request.xhr?
      render :partial => "shared/add_modules_list", :layout => false
    elsif request.post? and !session[:add_mods].nil?
      @unit.update_resources(session[:add_mods])
      @tutorial.update_users if @tutorial.shared?
      session[:add_mods] = nil
      redirect_to :action => "update", :id => @unit
    end
  end

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

  private

  def setSessionGuideId
    session[:tutorial_id] = @tutorial.id
    session[:guide_id] = nil
    session[:page_id] = nil
  end

  def unit_params
    params.require(:unit).permit :description, :title, :tag_list
  end
end
