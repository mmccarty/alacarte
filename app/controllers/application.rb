##########################################################################
#
#ICAP Tool - Publishing System for and by librarians.
#Copyright (C) 2007 Oregon State University
#
#This file is part of the ICAP project.
#
#The ICAP project is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#Questions or comments on this program may be addressed to:
#ICAP - Library Technology
#121 The Valley Library
#Corvallis OR 97331-4501
#
#http://ica.library.oregonstate.edu/about/index.html
#
########################################################################

# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
gem 'recaptcha'
class ApplicationController < ActionController::Base
include Spelling
include ReCaptcha::AppHelper

def module_types
  @types = MODULE_TYPES_ARRAY
end

 def create_module_object(object)
     type = object
     case type
      when 'Comments' then CommentResource.new
      when 'Course Widget' then CourseWidget.new
      when 'Custom Content' then MiscellaneousResource.new
      when 'Librarian Profile' then LibResource.new
      when 'Instructor Profile' then InstResource.new
      when 'Course Assignment' then AssignResource.new
      when 'Style Guides' then StyleResource.new
      when 'Plagiarism Information' then PlagResource.new
      when 'Recommendations' then  RecomResource.new
      when 'RSS Feeds' then RssResource.new
      when 'Databases' then DatabaseResource.new
      when 'Course Reserves' then ReserveResource.new
      when 'LibraryFind Search' then LibfindResource.new
   end    
 end
 
 #Authorizations

#check to see if a user is logged in, if not they are redirected to login 
  def authorize
    user = User.find_by_id(session[:user_id])

    unless user
      session[:original_uri] = request.request_uri #remember where the user was trying to go
      flash[:notice]= "Please log in"
      redirect_to(:controller=> "login", :action => "login")
      return false
    else
      @user = user
    end
  end

  #check to see if user is admin
  def authorize_admin
    user = User.find_by_id(session[:user_id])

    unless user
      session[:original_uri] = request.request_uri #remember where the user was trying to go
      flash[:notice] = "Please log in"
      redirect_to(:controller => "login", :action => "login")
      return false
    else
      if user.is_admin == false
        flash[:notice]= "You do not have admin access"
        redirect_to(:controller => :page, :action => :my_pages)
      else
        @admin = user
      end
    end
  end


#session varables

#returns customizations
 def local_customization
     @local = Local.find(:first)
 end

  #returns the current user in an admin session 
  def current_user
    unless User.find_by_id(session[:cuser])
      redirect_to(:controller => "admin", :action => "users" )
      return false
    else
      @user = User.find_by_id(session[:cuser])
    end

end

  #returns the current page in a session 
  def current_page
    unless Page.find_by_id(session[:page])
      redirect_to(:controller => "page", :action => "index" )
      return false
    else
      @page = Page.find_by_id(session[:page])
    end

end

#list of altered pages
 def altered_pages
    if session[:page_list] and !session[:page_list].empty?
       @altered_pages=[]
       session[:page_list].each do |pid|
           @altered_pages << @user.pages.find_by_id(pid)
       end
    else
       session[:page_list] = @altered_pages = nil
    end 
 end
 
  def current_guide
    unless Guide.find_by_id(session[:guide])
      redirect_to(:controller => "guide", :action => "index" )
      return false
    else
      @guide = Guide.find_by_id(session[:guide])
    end

end
 def current_tab
    tab = Tab.find_by_id(session[:current_tab])
    unless tab
      redirect_to(:controller => "guide", :action => "index" )
      return false
    else
      @tab =tab
    end

end

 def altered_guides
    if session[:guide_list] and !session[:guide_list].empty?
       @altered_guides=[]
       session[:guide_list].each do |gid|
            @altered_guides << @user.guides.find_by_id(gid)
       end
    else
       session[:guide_list] = @altered_guides = nil
    end 
 end
 
  #returns the current page in a session 
  def current_module
    unless find_mod(session[:mod_id],session[:mod_type])
      redirect_to(:controller => "module", :action => "index" )
      return false
    else
      @mod = find_mod(session[:mod_id],session[:mod_type])
    end

end

# clean up sessions



def clear_tab_sessions
  session[:current_tab] = nil if session[:current_tab]
  session[:tab] = nil if  session[:tab]
end

def clear_guide_sessions
  session[:guide] = nil if  session[:guide]
end

def clear_recent_edits
    session[:guide_list] = nil if session[:guide_list]
    session[:page_list] = nil if session[:page_list]
  
end
def clear_page_sessions
  session[:page] = nil if  session[:page]
end

def clear_module_sessions
  session[:mod_id] = nil if session[:mod_id]
  session[:mod_type] = nil if  session[:mod_type]
end

def clear_sessions
  clear_tab_sessions
  clear_guide_sessions
  clear_recent_edits
  clear_page_sessions
  clear_module_sessions
end

  
#subject and master subject lists

  #list the subject codes
  def get_subjects
    subjects = Subject.find(:all, :order => 'subject_code')
    @subj_list = []
    subjects.each do |sub|
      @subj_list << sub.subject_code
    end
    return @subj_list
  end

 #list the subject names
  def get_subject_values
    @subjects = Subject.find(:all, :order => 'subject_name')

  end
  
  #list the master subjects
  def get_guide_types
     @guide_types = Master.find(:all, :order => 'value')
  end
  
  
  def spellcheck
    headers['Content-Type'] = 'text/xml'
    headers['charset'] = 'utf-8'
    suggestions = check_spelling(params[:check], params[:cmd], params[:lang])
    xml = "<?xml version=\"1.0\" encoding=\"utf-8\" ?><badwords id=\"#{params[:id]}\" cmd=\"#{params[:cmd]}\">#{suggestions.join("+")}</badwords>"
    render :text => xml
    return
  end
  
  #create and add a resource to the HABTM relationship for user and page
  def create_and_add_resource(user, mod, page=nil, tab =nil)
     mod.update_attribute(:created_by, user.name)
     resource = Resource.create(:mod => mod)
     user.add_resource(resource)
     unless page == nil
       page.add_resource(resource)
     end
     unless tab == nil
       tab.add_resource(resource)
     end
  end
  
  #find a particular module
  def find_mod(id, type)
    eval(type).find(id)
  end
 
 
 
  
end
