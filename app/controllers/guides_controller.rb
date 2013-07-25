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
      @guide.add_master_type params[:types]
      @guide.add_related_subjects params[:subjects]
      redirect_to @guide
    else
      flash[:notice] = "Could not create the guide. There were problems with the following fields: #{@guide.errors.full_messages.join(", ")}"
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
    @guide.update_attributes params[:guide]
    if @guide.save
      @guide.add_master_type params[:types]
      @guide.add_related_subjects params[:subjects]
      redirect_to @guide and return
    else
      flash[:notice] = "Could not create the guide. There were problems with the following fields: #{@guide.errors.full_messages.join(", ")}"
      flash[:guide_title] = params[:guides][:guide_title]
      flash[:guide_title_error] = ""
      render :edit
    end
  end

  def copy
    @subjects = Subject.get_subject_values
    @guide_types = Master.get_guide_types
    session[:guides] = nil
    session[:current_tab] = nil

    begin
      @guide = @user.guides.find params[:id]
      @tag_list = @guide.tag_list
      @selected_types = @guide.masters.map &:id
      @selected_subjs = @guide.subjects.map &:id

      if request.post?
        @new_guide = @guide.dup
        @new_guide.update_attributes params[:guides]
        @new_guide.published = false
        @new_guide.add_tags params[:tags]

        if @new_guide.save
          @user.add_guide @new_guide
          @new_guide.add_master_type params[:types]
          @new_guide.add_related_subjects params[:subjects]

          if params[:options] == 'copy'
            @new_guide.copy_resources @user.id, @guide.tabs
          else
            @new_guide.copy_tabs @guide.tabs
          end

          session[:guides] = @new_guide.id
          session[:current_tab] = @new_guide.tabs.first.id
          redirect_to edit_guide_path(@new_guide) and return
        else
          flash[:error] = "Please edit the guide title. A guide with this title already exists."
        end
      end
    rescue
      redirect_to :action => 'index', :list=> 'mine'
    end
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
    begin
      user = @guide.users.find(params[:id])
    rescue Exception => e
      redirect_to :action => 'index', :list=> 'mine'
    else
      @guide.update_attribute(:created_by, @guide.users.at(1).name) if @guide.created_by.to_s == user.name.to_s
      user.delete_guide_tabs(@guide)
      flash[:notice] = "User(s) successfully removed."
      redirect_to :action => 'share', :id => @guide
    end
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
