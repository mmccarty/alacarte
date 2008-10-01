class IcaController < ApplicationController
before_filter :local_customization
layout :select_layout
  
  
 def index
     begin
      @page = Page.find(params[:id]) 
     rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid page #{params[object_id]}" )
      render :status => 404,
      :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
      :layout => false 
    else
      @meta_keywords = @page.tag_list 
      @meta_description = @page.page_description
       @related_guides = @page.related_guides
       @owner = @page.users.find(:first, :conditions => {:name => @page.created_by})
        @mod = @page.resource.mod if @page.resource
       if @page.template == 2
          @mods_left  = @page.left_modules
          @mods_right = @page.right_modules
      else
         @mods = @page.page_resources
      end
    end
 end
 
#Gets the list of all published ICAPs and filters the list by subject
 def published_pages
    @subj_list = get_subjects
    @pages = Page.get_published_pages(params[:subject],params[:term],params[:year]) 
    @tags = Page.tag_counts(:start_at => Time.now.last_year, :conditions =>["published = ?", true], :order => 'taggings.created_at desc', :limit => 100)
    if request.post?
        if params[:subject][:subject_code]
            @subj = params[:subject][:subject_code]
            @subject = Subject.find_by_subject_code(@subj)
            @pages = Page.get_published_pages(@subj, nil, nil) 
         end
    end
 end
 
 def archived
    @subj_list = get_subjects
    @pages = Page.get_archived_pages(nil) 
    @tags = Page.tag_counts(:start_at => Time.now.last_year, :conditions =>["published = ?", true], :order => 'taggings.created_at desc', :limit => 100)
    if request.post?
        if params[:subject][:subject_code]
            @subj = params[:subject][:subject_code]
            @subject = Subject.find_by_subject_code(@subj)
            @pages = Page.get_archived_pages(@subj) 
         end
    end  
 end
 
 
 def tagged
  @tag = params[:id]
  @tags = Page.tag_counts
  @pages = Page.find_tagged_with(@tag)
end

 def print
     begin
      @page = Page.find(params[:id]) 
     rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid page #{params[object_id]}" )
      render :status => 404,
      :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
      :layout => false 
    else
      @mods = @page.modules
     end
 end
 

 

 
 
 def select_layout
    if ['print'].include?(action_name)
      "print_page"
    elsif ['published_pages'].include?(action_name)
      "portal_template"
    elsif ['tagged'].include?(action_name)
      "portal_template"
    elsif ['archived'].include?(action_name)
      "portal_template"  
    else
     "icap_template"
    end
 end
  
end
