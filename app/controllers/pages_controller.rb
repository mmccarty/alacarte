class PagesController < ApplicationController
  include ActsPagey
  include Paginating
  layout 'admin'

  def new
    @page = Page.new
    @subj_list = Subject.get_subjects
    custom_page_data
  end

  def create
    @page = Page.new params[:page]
    if @page.save
      @user.add_page @page
      @page.add_subjects params[:page][:subject_ids].select(&:present?)
      redirect_to @page
    else
      @subj_list = Subject.get_subjects
      custom_page_data
      render :new
    end
  end

  def template
    @pages = Page.all
  end

  def edit
    @subj_list = Subject.get_subjects
    custom_page_data
    begin
      @page =  @user.pages.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to  :action => 'index' and return
    else
      @selected = @page.subjects.collect{|s| s.id}
      flash[:course_term] = @page.term
    end
  end

  def update
    @page = @user.pages.find params[:id]
    @page.update_attributes params[:page]
    @page.add_subjects params[:subjects] if params[:subjects].present?
    if @page.save
      redirect_to @page
    else
      render :edit
    end
  end

  def copy
    @page = @user.pages.find params[:id]
    if ! request.post?
      return
    end

    @new_page = @page.replicate @user, params[:options]
    @user.add_page @new_page

    redirect_to edit_page_path(@new_page)
  end

  def edit_contact
    begin
      @page = @user.pages.find params[:id]
      @tab = @page.tabs.first
    rescue ActiveRecord::RecordNotFound
      redirect_to pages_path and return
    else
      if request.put?
        @page.update_attributes params[:page]
        if @page.save
          flash[:notice] = "The Contact Module was successfully changed."
          redirect_to @page and return
        end
      else
        @resources = @user.contact_resources.map { |resource| [resource.mod.label, resource.id] }
      end
    end
  end

  def remove_user_from_page
    begin
      user = @page.users.find_by_id(params[:id])
    rescue Exception => e
      redirect_to :action => 'index', :list=> 'mine'
    else
      @page.update_attribute(:created_by, @page.users.at(1).name) if @page.created_by.to_s == @user.name.to_s
      user.delete_page_tabs(@page)
      flash[:notice] = "User(s) successfully removed."
      redirect_to :action => 'share', :id => @page
    end
  end

  def send_url
    @sucurrent = 'current'
    @page_url = url_for :controller => 'ica', :action => 'index', :id => @page
    @message =
      "A new library course guide has been created for #{@page.header_title}. The link to the page is: #{@page_url}. Please inform your students of the page and include the link in your course material.
Please contact me if you have any questions or suggestions.
-#{@user.name} "
    if request.post?
      if params[:email] and params[:body]
        begin
          Notifications.deliver_send_url(params[:email],@user.email,params[:body])
        rescue Exception => e
          flash[:notice] = "Could not send email"
          redirect_to  :action => "send_url" and return
        else
          flash[:notice]  = "The URL was successfully emailed."
          redirect_to :action => "send_url"
        end
      end
    end
  end

  def destroy
    begin
      page = Page.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :action => 'index' and return
    else
      if page.users.length == 1
        @user.pages.delete(page)
        page.destroy
      else
        page.update_attribute(:created_by, page.users.at(1).name) if page.created_by.to_s == @user.name.to_s
        @user.pages.delete(page)
      end
      if request.xhr?
        render :text => ""
      else
        redirect_to :back, :page => params[:page], :sort => params[:sort]
      end
    end
  end

  private

  def find_item
    @page = @user.pages.find params[:id]
    @page_owners = @page.users
    @item_name = @page.search_title
    @page
  end

  def get_item
    @page
  end

  def item_name
    @page.header_title
  end
end
