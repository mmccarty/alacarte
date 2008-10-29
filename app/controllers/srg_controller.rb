class SrgController < ApplicationController
before_filter :local_customization

   layout :select_layout
 
  def index
      @mods_left= []
      @mods_right=[]
     begin
      @guide = Guide.find(params[:id]) 
     rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid guide #{params[object_id]}" )
      render :status => 404,
      :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
      :layout => false 
    else
      @meta_keywords = @guide.tag_list 
      @meta_description = @guide.description
      @owner = @guide.users.find(:first, :conditions => {:name => @guide.created_by})
      @mod = @guide.resource.mod if @guide.resource
      @related_guides = @guide.related_guides
      @related_pages = @guide.related_pages
      @tabs = @guide.tabs
      @tab = params[:tab] ?  @tabs.find(params[:tab]) : @tabs.find(:first)
      if @tab and @tab.template == 2
          @mods_left  = @tab.left_modules
          @mods_right = @tab.right_modules
      elsif @tab
        @mods = @tab.tab_resources
      else
        render :status => 404,
        :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
        :layout => false
      end
      
    end
  end
  
  def show_tab
     @mods_left= []
      @mods_right=[]
     begin
      @guide = Guide.find(params[:gid]) 
     rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid guide #{params[object_id]}" )
      render :status => 404,
      :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
      :layout => false 
    else
      @mod = @guide.resource.mod if @guide.resource
      @related_guides = @guide.related_guides
      @related_pages = @guide.related_pages
      @tabs = @guide.tabs
      
      @tab = @tabs.find(params[:id])
      if @tab.template ==2
        @mods_left  = @tab.odd_modules
        @mods_right = @tab.even_modules
      else
        @mods = @tab.tab_resources
      end
      render :action => 'index'
  end
end

def published_guides
     @guides = Guide.find(:all,:conditions => {:published => true}, :order => 'guide_name')
    @masters = Master.find(:all, :order => 'value')
    @tags = Guide.tag_counts(:start_at => Time.now.last_year, :conditions =>["published = ?", true], :order => 'taggings.created_at desc', :limit => 100)
end

def search
    @gtags = Guide.tag_counts(:start_at => Time.now.last_year, :conditions =>["published= ?", true], :order => 'taggings.created_at desc', :limit => 100) 
    @ptags = Page.tag_counts(:start_at => Time.now.last_year, :conditions =>["published= ?", true], :order => 'taggings.created_at desc', :limit => 100) 

end

def tagged
  @tag = params[:id]
  @tags = Guide.tag_counts(:start_at => Time.now.last_year, :conditions =>["published = ?", true], :order => 'taggings.created_at desc', :limit => 100)
  @guides = Guide.find_tagged_with(@tag)
end

def print
   @mods=[]
     begin
       @guide = Guide.find(params[:id]) 
     rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid page #{params[object_id]}" )
      render :status => 404,
      :text => (IO.read(File.join(RAILS_ROOT, 'public', '404.html'))) ,
      :layout => false 
    else
      @guide.tabs.each do |tab|
        tab.modules.each do |mod|
           @mods << mod
        end
      end
      return @mods
     end
 end
 

  def select_layout
    if ['print'].include?(action_name)
      "print_page"
    elsif ['index'].include?(action_name)
      "srg_template" 
    elsif ['show_tab'].include?(action_name)
      "srg_template"   
    else
     "portal_template"
    end
 end
 
 end
