class DashboardController < ApplicationController
before_filter :authorize
before_filter :clear_recent_edits

  def index
    @dcurrent = 'current'
  
  end
  
  def my_profile
     begin
     resource = @user.resources.find(params[:rid]) 
    rescue Exception => e
      logger.error("Exception in show: #{e}" )
      flash[:notice] = "Invalid module"
      redirect_to :index
    else
       @mod = resource.mod
    end
    
    
  end
  
  def edit_profile
   @resources = @user.contact_resources
   @selected = @user.rid
    if request.post?
     if  params[:contact] != "Select"
        @user.add_profile(params[:contact])
        resource = @user.resources.find(params[:contact]) 
        @mod = resource.mod
        flash[:notice]="Profile Saved"
        redirect_to :action => 'my_profile' , :rid =>params[:contact]
       else
         flash[:notice]="Please select a module from the list."
         redirect_to :action => 'edit_profile'
      end
    end
 end
 
  
  def my_account
    if request.post?
      if @user.update_attributes(:password=>params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
        flash[:notice]="Password Changed"
        redirect_to(:action => 'my_account')
      
      end
    end
  end
  
  def account_info
  if request.post?
      if @user.update_attribute(:name, params[:user][:name])and @user.update_attribute(:email, params[:user][:email])
        flash[:notice]="Account Changed"
        redirect_to(:action => 'my_account')
      else
        flash[:notice]="Account Not Changed"
        redirect_to(:action => 'my_account')
      end
    end
  end
  

  
end
