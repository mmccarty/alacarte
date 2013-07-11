class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery
  before_filter :authorize
  before_filter :local_customization

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
      session[:original_uri] = request.request_uri
      flash[:notice]= "Please log in"
      redirect_to login_path and return
    end
  end

  def student_authorize
    student = Student.find_by_id_and_tutorial_id(session[:student],session[:tutorial])
    unless student
      session[:tut_uri] = request.request_uri
      redirect_to(:controller=> "student", :action => "login", :id => session[:tutorial]) and return
    else
      @student = student
    end
  end

  def authorize_admin
    user = User.find_by_id(session[:user_id])

    unless user and  user.is_admin == true
      session[:original_uri] = request.request_uri
      flash[:notice]= "Please log in"
      redirect_to(:controller=> "login", :action => "login")
      return false
    else
      @admin = user
      return true
    end
  end

  # Constructs one of the derived resource object types, by name.
  def create_module_object(type)
    type.camelize.constantize.new
  end

  # Finds a resource object given the id and type name.
  def find_mod(id, type)
    type.constantize.find id
  end

  # Creates a "resource" to associate a user with a module (derived resource).
  def create_and_add_resource(user, mod, item = nil)
    user.create_and_add_resource mod, item
  end

  # Abbreviates a chunk of text.
  def create_slug(text, trunc = 25, truncate_string = '...')
    if text
      l = trunc - truncate_string.mb_chars.length
      chars = text.mb_chars
      (chars.length > trunc ? chars[0...l] + truncate_string : text).to_s
    end
  end

  # Return a list of all the derived resource types in a format suitable for use in a select tag.
  def module_types
    @types = local_customization.mod_types
  end

  # Returns the database record containing the local customizations.
  def local_customization
    @local = Local.first
  end

  def custom_page_data
    @terms = TERMS
    @years = YEARS
    @campus = CAMPUS
  end

  def current_page
    @page = Page.find session[:page] if session[:page]
  end

  def current_guide
    @guide = Guide.find session[:guides] if session[:guides]
  end

  def current_tab
    @tab = Tab.find session[:current_tab] if session[:current_tab]
  end

  def current_module
    @mod = find_mod session[:mod_id], session[:mod_type] if session[:mod_id] and session[:mod_type]
  end

  def current_tutorial
    @tutorial = Tutorial.find session[:tutorial] if session[:tutorial]
  end

  def current_student
    @student = Student.find_by_id_and_tutorial_id(session[:student],session[:tutorial])
    @student ? @student : (@student = session[:student] = nil)
  end

  def current_unit
    @unit = Unit.find(session[:unit]) if session[:unit]
  end

  def clear_tab_sessions
    session[:current_tab] = nil if session[:current_tab]
    session[:tab] = nil if  session[:tab]
    session[:page_tabs] = nil if  session[:page_tabs]
    session[:tabs] = nil if  session[:tabs]
  end

  def clear_guide_sessions
    session[:guides] = nil if  session[:guides]
  end

  def clear_tutorial_sessions
    session[:tutorial] = nil if  session[:tutorial]
    session[:unit] = nil if session[:unit]
  end

  def clear_page_sessions
    session[:page] = @page = nil if  session[:page]
  end

  def clear_module_sessions
    session[:mod_id] = nil if session[:mod_id]
    session[:mod_type] = nil if  session[:mod_type]
  end

  def clear_unit
    session[:unit] = nil if session[:unit]
  end

  def clear_student
    session[:student] = nil if session[:student]
    session[:saved_student] = nil if session[:saved_student]
  end

  def clear_sessions
    clear_tab_sessions
    clear_guide_sessions
    clear_page_sessions
    clear_module_sessions
    clear_tutorial_sessions
    clear_student
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
    render :template => "errors/500",  :status => :internal_server_error
  end
end
