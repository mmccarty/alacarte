class GuidesController < ApplicationController
  include ActsPagey
  include Paginating
  layout 'admin'

  def index
    @sort   = params[:sort] || 'name'
    @guides = @user.sort_guides @sort
    @guides = paginate_guides @guides, (params[:page] ||= 1), @sort
  end

  def new
    @guide = Guide.new
    @masters = Master.get_guide_types
    @subjects = Subject.get_subject_values
    @resources = @user.contact_resources
  end

  def create
    @guide = Guide.new params[:guide]
    if @guide.save
      @user.add_guide @guide
      @guide.add_master_type params[:guide][:master_ids].select(&:present?)
      @guide.add_related_subjects params[:guide][:subject_ids].select(&:present?)
      redirect_to @guide
    else
      flash[:notice] = "Could not create the guide. There were problems with the following fields: #{@guide.errors.full_messages.join(", ")}"
      @masters = Master.get_guide_types
      @subjects = Subject.get_subject_values
      render :new
    end
  end

  def edit
    begin
      @guide = @user.guides.find params[:id]
      @masters = Master.get_guide_types
      @subjects = Subject.get_subject_values
      @resources = @user.contact_resources
    rescue ActiveRecord::RecordNotFound
      redirect_to guides_path
    end
  end

  def update
    @guide = @user.guides.find params[:id]
    if @guide.update_attributes params[:guide]
      redirect_to @guide
    else
      flash[:notice] = "Could not create the guide. There were problems with the following fields: #{@guide.errors.full_messages.join(", ")}"
      flash[:guide_title] = params[:guide][:guide_title]
      flash[:guide_title_error] = ""
      @masters = Master.get_guide_types
      @subjects = Subject.get_subject_values
      render :edit
    end
  end

  def copy
    @guide = @user.guides.find params[:id]
    if ! request.post?
      return
    end

    # TODO: Copy logic should be moved to the model.
    @new_guide = @guide.dup
    @new_guide.guide_name = "#{ @guide.guide_name }-copy"
    if params[:options] == 'copy'
      @new_guide.copy_resources @user.id, @guide.tabs
    else
      @new_guide.copy_tabs @guide.tabs
    end
    @user.add_guide @new_guide

    @new_guide.add_tags @guide.tag_list
    @new_guide.add_master_type @guide.masters.map(&:id)
    @new_guide.add_related_subjects @guide.subjects.map(&:id)

    redirect_to edit_guide_path(@new_guide)
  end

  def edit_contact
    begin
      @guide = @user.guides.find params[:id]
      @tab = @guide.tabs.first
    rescue ActiveRecord::RecordNotFound
      redirect_to guides_path and return
    else
      if request.put?
        @guide.update_attributes params[:guide]
        if @guide.save
          flash[:notice] = "The Contact Module was successfully changed."
          redirect_to @guide and return
        end
      else
        @resources = @user.contact_resources.map { |resource| [resource.mod.label, resource.id] }
      end
    end
  end

  def remove_user_from_guide
    @guide = Guide.find params[:id]
    user = @guide.users.find params[:user]
    user.delete_guide_tabs(@guide)
    if @guide.created_by.to_s == user.name.to_s and @guide.users.length > 0
      @guide.update_attribute(:created_by, @guide.users.first.name)
    end
    flash[:notice] = "User(s) successfully removed."
    redirect_to :action => 'share', :id => @guide
  end

  def destroy
    begin
      guide = @user.guides.find params[:id]
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => 'index'
    else
      if guide.users.length == 1
        @user.guides.delete guide
        guide.destroy
      else
        guide.update_attribute(:created_by, guide.users.at(1).name) if guide.created_by.to_s == @user.name.to_s
        @user.guides.delete guide
      end
      render nothing: true
    end
  end

  private

  def find_item
    @guide = @user.guides.find params[:id]
  end
end
