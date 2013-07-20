class GuidesController < ApplicationController
  include Paginating
  layout 'admin'

  def index
    @sort   = params[:sort] || 'name'
    @guides = @user.sort_guides(@sort)
    @guides = paginate_guides(@guides,(params[:page] ||= 1), @sort)
  end

  def show
    begin
      @guide = @user.guides.find params[:id]
      session[:guides] = @guide.id
      @tabs = @guide.tabs
      if session[:current_tab]
        @tab = @tabs.select { |t| t.id == session[:current_tab].to_i }.first
      end
      unless @tab
        @tab = @tabs.first
        session[:current_tab] = @tab.id
      end
      if @tab.template ==2
        @mods_left  = @tab.left_resources
        @mods_right = @tab.right_resources
      else
        @mods = @tab.tab_resources
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to guides_path
    end
  end

  def new
    @guide = Guide.new
    @masters = Master.get_guide_types
    @subjects = Subject.get_subject_values
    @resources = @user.contact_resources
  end

  def create
    guide = Guide.new params[:guide]
    guide.create_home_tab
    if guide.save
      @user.add_guide guide
      guide.add_master_type params[:types]
      guide.add_related_subjects params[:subjects]
      redirect_to guide
    else
      flash[:notice] = "Could not create the guide. There were problems with the following fields: #{guide.errors.full_messages.join(", ")}"
      redirect_to guides_path
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
    begin
      guide = @user.guides.find params[:id]
      if guide.save
        guide.add_master_type params[:types]
        guide.add_related_subjects params[:subjects]
        redirect_to guide and return
      else
        flash[:notice] = "Could not create the guide. There were problems with the following fields: #{@guide.errors.full_messages.join(", ")}"
        flash[:guide_title] = params[:guides][:guide_title]
        flash[:guide_title_error] = ""
        redirect_to guides_path and return
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to guides_path and return
    end
  end

  def copy
    @subjects = Subject.get_subject_values
    @guide_types = Master.get_guide_types
    session[:guides] = nil
    session[:current_tab] = nil
    begin
      @guide = @user.guides.find params[:id]
    rescue
      redirect_to :action => 'index', :list=> 'mine'
    else
      @tag_list = @guide.tag_list
      @selected_types = @guide.masters.map &:id
      @selected_subjs = @guide.subjects.map &:id
      if request.post?
        @new_guide = @guide.clone
        @new_guide.attributes = params[:guides]
        @new_guide.published = false
        @new_guide.add_tags(params[:tags])
        if @new_guide.save
          @user.add_guide(@new_guide)
          @new_guide.add_master_type params[:types]
          @new_guide.add_related_subjects params[:subjects]
          if params[:options]=='copy'
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
    end
  end

  def set_owner
    begin
      @guide = @user.guides.find params[:id]
    rescue
      redirect_to :action => 'index', :list=> 'mine' and return
    end
    @owner = User.find params[:uid]
    @guide.update_attribute :created_by, @owner.name
    @guide_owners = @guide.users
    if request.xhr?
      render :partial => 'owners', :layout => false
    else
      redirect_to :action => 'share', :id => @guide.id
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

  def edit_relateds
    begin
      @guide = @user.guides.find params[:id]
      @tab = @guide.tabs.first
    rescue ActiveRecord::RecordNotFound
      redirect_to guides_path and return
    end
    if request.put?
      @guide.add_related_guides params[:relateds] if params[:relateds]
      if @guide.save
        flash[:notice] = "The guides were successfully related"
        redirect_to @guide and return
      end
    else
      @guides   = Guide.published_guides
      @relateds = @guide.related_guides.map &:id
    end
  end

  def remove_related
    @guide.delete_relateds(params[:gid]) if params[:gid]
    flash[:notice] = "The guide was successfully removed"
    redirect_to :action => 'edit_relateds', :id => @guide
  end

  def suggest_relateds
    @relateds = @guide.suggested_relateds
    @guides = Guide.published_guides
    render :partial => "relateds", :layout => false
  end

  def share
    begin
      @guide = @user.guides.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Successfully removed from shared guide."
      redirect_to :action => 'index'
    else
      session[:guides] = @guide.id
      session[:current_tab] = @guide.tabs.first.id
      @user_list = User.order("name")
      @guide_owners = @guide.users
      url = url_for :controller => 'srg', :action => 'index', :id => @guide
      @message =
        "I've shared #{@guide.guide_name} with you. The link to the guide is: #{url} .  -#{@user.name} "
    end
  end

  def share_update
    @guide = @user.guides.find(params[:id])
    to_users = []
    if params[:users] != nil
      params[:users].each do |p|
        new_user = User.find(p)
        if new_user and !@guide.users.include?(new_user)
          @guide.share(new_user.id,params[:copy])
          to_users << new_user
        end
      end
      flash[:notice] = "User(s) successfully added and email notification sent."
      send_notices(to_users, params[:body]) if params[:body]
    else
      flash[:notice] = "Please select at least one user to share with."
    end
    redirect_to :action => 'share', :id => @guide.id and return
  end

  def send_notices(users, message)
    users.each do |p|
      user = User.find(p)
      begin
        Notifications.deliver_share_guide(user.email,@user.email, message)
      rescue Exception => e
        flash[:notice] = "User(s) successfully added. Could not send email"
      else
        flash[:notice] = "User(s) successfully added and email notification sent."
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
      guide = @user.guides.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => 'index'
    else
      if guide.users.length == 1
        @user.guides.delete(guide)
        guide.destroy
      else
        guide.update_attribute(:created_by, guide.users.at(1).name) if guide.created_by.to_s == @user.name.to_s
        @user.guides.delete(guide)
      end
      if request.xhr?
        render :text => ""
      else
        redirect_to :back, :page => params[:page], :sort => params[:sort]
      end
    end
  end

  def publish
    begin
      @guide = @user.guides.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => 'index'
    else
      if request.xhr?
        render :update do |page|
          if @guide.toggle_published
            page.replace_html "publish#{@guide.id}" , :partial => "publish" ,:locals => {:guides => @guide, :page => @page, :sort => @sort }
          else
            flash[:error] = "A contact module is required before you can publish the guide."
            flash[:contact_error] = ""
            page.redirect_to  :action => 'edit_contact', :id => @guide
          end
        end
      else
        if @guide.toggle_published
          redirect_to :back, :sort=> params[:sort], :page => params[:page]
        else
          flash[:error] = "A contact module is required before you can publish the guide."
          flash[:contact_error] = ""
          redirect_to  :action => 'edit_contact', :id => @guide
        end
      end
    end
  end
end
