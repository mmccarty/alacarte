module ActsPagey
  extend ActiveSupport::Concern

  def show
    item = find_item
    @tabs = item.tabs
    if @tabs.blank?
      item.create_home_tab
      @tabs = item.tabs
    end
    if session[:current_tab]
      @tab = @tabs.select { |t| t.id == session[:current_tab].to_i }.first
    end
    unless @tab
      @tab = @tabs.first
      session[:current_tab] = @tab.id
    end
    if @tab.template == 2
      @mods_left  = @tab.left_resources
      @mods_right = @tab.right_resources
    else
      @mods = @tab.tab_resources
    end
  end

  def set_owner
    item = find_item
    @owner = User.find params[:uid]
    item.update_attribute :created_by, @owner.name
    @owners = item.users
    redirect_to action: :share
  end

  def edit_relateds
    item = find_item
    @tab = item.tabs.first

    if request.put?
      item.add_related_guides params[:relateds] if params[:relateds]
      if item.save
        flash[:notice] = "The guides were successfully related"
        redirect_to item and return
      end
    else
      @guides   = Guide.published_guides
      @relateds = item.related_guides.map &:id
    end
  end

  def remove_related
    item = find_item
    item.delete_relateds(params[:gid]) if params[:gid]
    flash[:notice] = "The guide was successfully removed"
    redirect_to action: :edit_relateds
  end

  def suggest_relateds
    item = find_item
    @relateds = item.suggested_relateds
    @guides = Guide.published_guides
    render :partial => "relateds", :layout => false
  end

  def publish
    item = find_item
    item.toggle! :published
    item.update_attribute :archived, false
    if request.xhr?
      @sort = params[:sort]
      render :partial => "index_row" ,:locals => {:id => page, :page => params[:page], :sort => @sort , :all => params[:all]}
    else
      redirect_to :back, :page => params[:page], :sort => params[:sort]
    end
  end

  def archive
    item = find_item
    item.toggle! :archived
    item.update_attribute :published, false
    if request.xhr?
      @sort = params[:sort]
      render :partial => "index_row" ,:locals => {:id => page, :page => params[:page], :sort => @sort , :all => params[:all]}
    else
      redirect_to :back, :page => params[:page], :sort => params[:sort]
    end
  end

  def share
    item = find_item
    session[:current_tab] = item.tabs.first.id
    @user_list = User.order("name")
    @guide_owners = item.users
    url = url_for :controller => 'srg', :action => 'index', :id => @guide
    @message =
        "I've shared #{@guide.guide_name} with you. The link to the guide is: #{url} .  -#{@user.name} "
  end

  def share_update
    item = find_item
    to_users = []
    if params[:users] != nil
      params[:users].each do |p|
        new_user = User.find(p)
        if new_user and !item.users.include?(new_user)
          item.share(new_user.id,params[:copy])
          to_users << new_user
        end
      end
      flash[:notice] = "User(s) successfully added and email notification sent."
      send_notices(to_users, params[:body]) if params[:body]
    else
      flash[:notice] = "Please select at least one user to share with."
    end
    redirect_to :action => :share, id: item
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

  def toggle_columns
    item = find_item
    if item.template == 2
      item.update_attribute :template, 1
    else
      item.update_attribute :template, 2
    end
    redirect_to :action => "edit", :id => item
  end
end
