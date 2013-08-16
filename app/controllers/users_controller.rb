class UsersController < ApplicationController
  before_filter :authorize_admin
  layout 'admin'

  def index
    @all   = params[:all]
    @users = User.where("role <> 'pending'").order(:name)
    @users =  (@all == "all" ? @users : @users.paginate(:per_page => 30, :page => params[:page]))
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new params[:user]
    url = login_url
    if @user.save
      begin
        Notifications.deliver_add_user(@user.email, @admin.email, @user.password, url)
      rescue Exception => e
        flash[:notice] = "Could not send email"
        #render :new and return
      end
      flash[:notice] = "User successfully added."
      redirect_to users_path and return
    else
      render :new
    end
  end

  def edit
    @user = User.find params[:id]
  end

  def update
    @user = User.find params[:id]
    @user.update_attributes params[:user]
    if @user.save
      flash[:notice] = 'User was successfully updated.'
      redirect_to users_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash.now[:notice] = "User(s) successfully deleted."
    if request.xhr?
      render :text => ""
    else
      redirect_to users_path
    end
  end

  def email_list
    @emails = User.all.collect(&:email).join(', ')
  end

  def pending
    @users = User.where(:role => 'pending').paginate :per_page => 30, :page => params[:page]
  end

  def approve
    @user = User.find(params[:id])
    if @user.update_attribute('role', 'author')
      begin
        url = url_for :controller => 'login', :action => 'login'
        Notifications.deliver_accept_nonsso_pending_user(@user.email, @local.admin_email_from, @user.password, url)

      rescue Exception => e
        logger.error("Exception in register user: #{e}}" )
        flash[:notice] = "User was successfully approved but email was not able to be sent"
      end
      flash[:notice] = 'User was successfully approved.'
    else
      flash[:notice] = 'User was not approved.'
    end
    redirect_to :action => 'pending_users' and return
  end

  def deny
    @user = User.find(params[:id])
    email = @user.email
    @user.destroy
    begin
      Notifications.deliver_reject_pending_user(email, @local.admin_email_from)
    rescue Exception => e
      logger.error("Exception in register user: #{e}}" )
      flash.now[:notice] = "User was successfully deleted but email was not able to be sent"
    end

    flash[:notice] = "User successfully deleted."
    redirect_to :action => 'pending_users'
  end
end
