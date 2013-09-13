class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery
  before_filter :authorize
  before_filter :local_customization
  before_filter :set_cache_buster
  before_filter :set_gettext_locale

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, :with => :render_500
    rescue_from ActiveRecord::RecordNotFound, ActionController::RoutingError, ActionController::UnknownController, ActionController::UnknownAction, :with => :render_404
    rescue_from RuntimeError, :with => :render_500
  end

  def authorize
    user = User.find_by_id session[:user_id]
    if user
      @user = user
    else
      if request.respond_to? :request_uri then
        session[:original_uri] = request.request_uri
      end
      flash[:notice]= "Please log in"
      redirect_to login_path
    end
  end

  def authorize_admin
    user = User.find_by_id(session[:user_id])

    unless user and  user.is_admin == true
      if request.respond_to? :request_uri then
        session[:original_uri] = request.request_uri
      end
      flash[:notice]= "Please log in"
      redirect_to(:controller=> "login", :action => "login")
      false
    else
      @admin = user
      true
    end
  end

  def create_node_object
    Node.new
  end

  def find_mod id
    Node.find id
  end

  def create_and_add_node user, mod, item = nil
    user.create_and_add_node mod, item
  end

  def create_slug text, trunc = 25, truncate_string = '...'
    if text
      l = trunc - truncate_string.mb_chars.length
      chars = text.mb_chars
      (chars.length > trunc ? chars[0...l] + truncate_string : text).to_s
    end
  end

  def local_customization
    @local = Local.first
  end

  def custom_page_data
    @terms = TERMS
    @years = YEARS
    @campus = CAMPUS
  end

  private

  def render_404(exception=nil)
    unless exception == nil
      log_error(exception)
    end
    render :template => "errors/404", :status => :not_found
  end

  def render_500(exception)
    log_error(exception)
    notify_about_exception(exception)
    render :template => "errors/500", :status => :internal_server_error
  end
end
