class DashboardsController < ApplicationController
  layout 'admin'

  def show
    @num_published_pages = @user.published_pages.length
    @num_archived_pages = @user.archived_pages.length
    @num_published_guides = @user.published_guides.length
    @num_nodes = @user.num_nodes
    @recent_activity = @user.recent_activity
  end

  def my_profile
    begin
      @mod = @user.nodes.find(params[:rid]).mod
    rescue
      redirect_to dashboard_path
    end
  end

  def edit_profile
    @resources = @user.contact_nodes
    @selected = @user.node_id || ""
    if request.post?
      if  params[:contact] != "Select"
        @user.add_profile params[:contact]
        flash[:notice] = "Profile Saved"
        redirect_to my_profile_dashboard_path(:rid => params[:contact]) and return
      else
        flash[:notice] = "Please select a module from the list."
        redirect_to edit_profile_dashboard_path and return
      end
    end
  end

  def my_account
    if request.post?
      if @user.update_attributes params[:user]
        flash[:notice]="Account Changed"
        redirect_to dashboard_path and return
      end
    end
  end
end
