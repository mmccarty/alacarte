class AdminController < ApplicationController
  before_filter :authorize_admin

  def index
    @user_count      = User.count
    @page_count      = Page.count
    @guide_count     = Guide.count
    @tutorial_count  = Tutorial.count
    @ppage_count     = Page.where(published: true).count
    @apage_count     = Page.where(archived: true).count
    @pguide_count    = Guide.where(published: true).count
    @ptutorial_count = Tutorial.where(published: true).count
  end

  def auto_archive
    pages = Page.where(:published => true)
    guides = Guide.where(:published => true)
    tutorials = Tutorial.where(:published => true)
    pages.each do |page|
      if page.updated_at < Time.now.months_ago(6)
        page.toggle!(:archived)
        page.update_attribute(:published, false)
      end
    end
    guides.each do |guide|
      if guide.updated_at < Time.now.months_ago(12)
        guide.toggle!(:published)
      end
    end
    tutorials.each do |tutorial|
      if tutorial.updated_at < Time.now.months_ago(12)
        tutorial.toggle!(:archived)
        tutorial.update_attribute(:published, false)
      end
    end
    redirect_to :back
  end

  %w(guide page tutorial).each do |name|

    define_method "#{ name }s" do
      @user = User.find params[:id]
      session[:author] = @user.id
      items = @user.send "#{ name }s"
      instance_variable_set "@#{ name }s", items
      @count = items.size
    end

    define_method "destroy_#{ name }" do
      item = Kernel.const_get("#{ name.titlecase }").find params[:id]
      @user = User.find session[:author]
      if item.users.length == 1 # if only one owner delete the page
        @user.send("#{ name }s").delete item
        item.destroy
      else # just delete the association
        @user.send("#{ name }s").delete item
      end
      flash[:notice] = "#{ name.titlecase } successfully deleted."
      redirect_to :back
    end

    define_method "archive_#{ name }" do
      item = Kernel.const_get("#{ name.titlecase }").find params[:id]
      if name != 'guide'
        item.toggle! :archived
      end
      item.update_attribute :published, false
      redirect_to  :back
    end

    define_method "assign_#{ name }" do
      begin
        item = Kernel.const_get("#{ name.titlecase }").find params[:id]
        instance_variable_set "@#{ name }", item
        session["#{ name }s"] = item.id
        @user_list = User.order :name
        instance_variable_set "@#{ name }_owners", item.users
      rescue ActiveRecord::RecordNotFound
        redirect_to :action => 'tools'
      end
    end

    define_method "#{ name }_update" do
      item = Kernel.const_get("#{ name.titlecase }").find params[:id]
      instance_variable_set "@#{ name }", item
      to_users = []
      if params[:users] != nil
        params[:users].each do |p|
          new_user = User.find p
          if new_user and !item.users.include? new_user
            item.share new_user.id, nil
            to_users << new_user
          end
        end
        flash[:notice] = "User(s) successfully added and email notification sent."
        send "#{ name }_send_notices", to_users
      else
        flash[:notice] = "Please select at least one user to share with."
      end
      redirect_to :action => "assign_#{ name }", :id => item.id and return
    end

    define_method "#{ name }_send_notices" do |users|
      item = Kernel.const_get("#{ name.titlecase }").find params[:id]
      instance_variable_set "@#{ name }", item
      users.each do |p|
        new_user = User.find(p)
        begin
          Notifications.send "deliver_share_#{ name }", new_user.email, @user.email, item.item_name
        rescue Exception => e
          flash[:notice] = "User(s) successfully added. Could not send email"
        else
          flash[:notice] = "User(s) successfully added and email notification sent."
        end
      end
    end

    define_method "remove_user_from_#{ name }" do
      begin
        item = Kernel.const_get("#{ name.titlecase }").find params[:id]
      rescue Exception => e
        redirect_to :action => 'tools', :list=> 'mine'
      else
        instance_variable_set "@#{ name }", item
        user = item.users.find_by_id params[:uid]
        item.update_attribute(:created_by, item.users.at(1).name) if item.created_by.to_s == user.name.to_s
        if name == 'tutorial'
          item.remove_from_shared user
        else
          user.send "delete_#{ name }_tabs", item
        end
        flash[:notice] = "User(s) successfully removed."
        redirect_to :action => "assign_#{ name }", :id => item
      end
    end
  end

  def view_customizations
  end

  def customize_layout
    if request.post?
      @local.update_attributes params[:local]
      redirect_to action: 'view_customizations' if @local.save
    end
  end

  def customize_content_types
    @guide_types = [['Course Guides', 'pages'], ['Subject Guides', 'guides'], ['Research Tutorials', 'tutorials']]
    @types = ::MODULES
    @selected = @local.types_list
    @selected_guides = @local.guides_list
    if request.post?
      @local.update_attributes params[:local]
      redirect_to action: 'view_customizations' if @local.save
    end
  end

  def customize_admin_email
    if request.post?
      @local.update_attributes params[:local]
      redirect_to action: 'view_customizations' if @local.save
    end
  end
end
