module ActsPagey
  extend ActiveSupport::Concern

  def index
    klass = self.class.to_s.underscore.split('_').first
    @sort  = params[:sort] || 'name'
    @items = @user.send "sort_#{ klass }", @sort
    @items = send "paginate_#{ klass }", @items, params[:page] ||= 1, @sort
    @item_type = klass.singularize
    render 'shared/index'
  end

  def show
    @tab = find_tab
    if @tab.num_columns == 1
      @mods = @tab.sorted_nodes
    else
      @mods_left  = @tab.left_nodes
      @mods_right = @tab.right_nodes
    end

    @item = get_item
    @header_name = item_name
    render 'shared/show'
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

  def copy
    @item = find_item
    @header_name = item_name
    if ! request.post?
      render 'shared/copy'
      return
    end

    @new_item = @item.replicate @user, params[:options]
    @user.send "add_#{ @new_item.class.to_s.downcase }", @new_item

    redirect_to polymorphic_path([@new_item], action: :edit)
  end

  def publish
    item = find_item
    item.toggle! :published
    if item.respond_to?(:archived=) && item.published?
      item.update_attribute :archived, false
    end
    if request.xhr?
      render nothing: true
    else
      redirect_to :back, page: params[:page], sort: params[:sort]
    end
  end

  def archive
    item = find_item
    item.toggle! :archived
    item.update_attribute :published, false
    if request.xhr?
      render nothing: true
    else
      redirect_to :back, :page => params[:page], :sort => params[:sort]
    end
  end

  def share
    @item = find_item
    if request.get?
      session[:current_tab] = @item.tabs.first.id
      @user_list = User.order("name")
      url = subject_guide_url @item
      @message =
          "I've shared #{@item_name} with you. The link to this is here: #{url} .  -#{@user.name} "
      render 'shared/share'
    elsif request.post?
      to_users = []
      if params[:users] != nil
        params[:users].each do |p|
          new_user = User.find(p)
          if new_user and !@item.users.include?(new_user)
            @item.share(new_user.id,params[:copy])
            to_users << new_user
          end
        end
        flash[:notice] = "User(s) successfully added and email notification sent."
        send_notices(to_users, params[:body]) if params[:body]
      else
        flash[:notice] = "Please select at least one user to share with."
      end
      redirect_to :action => :share, id: @item
    end
  end

  def send_notices(users, message)
    users.each do |p|
      user = User.find(p)
      begin
        Notifications.send_message(user.email,
                                   @user.email,
                                   message,
                                   "Shared Library a la Carte #{ @item.class.to_s}").deliver
      rescue Exception => e
        flash[:notice] = "User(s) successfully added. Could not send email"
      else
        flash[:notice] = "User(s) successfully added and email notification sent."
      end
    end
  end

  def toggle_columns
    find_tab.toggle_columns
    redirect_to find_item
  end

  def sort_tabs
    if params['tab_ids']
      ordered_tabs = params['tab_ids']
      ordered_tabs.each do |id|
        tab = Tab.find id
        tab.update_attribute(:position, ordered_tabs.index(id) + 1)
      end
    end
    render :nothing => true
  end

  def find_tab
    @parent = find_item
    if @parent.tabs.blank?
      @parent.create_home_tab
    end

    @tabs = @parent.tabs

    @tab = @tabs.where(id: session[:current_tab]).first if session[:current_tab]
    @tab ||= @tabs.first
    session[:current_tab] = @tab.id

    @tab
  end
end
