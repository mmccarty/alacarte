class IcaController < ApplicationController
  skip_before_filter :authorize
  before_filter :custom_page_data, :only => [:published_pages]
  layout 'template'

  def show
    @page = Page.includes(:users, :resource, :tags, {:tabs => :tab_resources}).find(params[:id])
    @tabs = @page.tabs
    @tab = params[:tab] ? @tabs.select{|t| t.id == params[:tab].to_i}.first : @tabs.first
    if @tab and @tab.template == 2
      @style ='width:270px; height:250px;'
      @mods_left  = @tab.left_modules
      @mods_right = @tab.right_modules
    elsif @tab
      @style ='width:505px; height:450px;'
      @mods = @tab.sorted_modules
      @mods_left, @mods_right = [], []
    else
      render_404
    end
    @title= @page.header_title + " | " + @local.ica_page_title
    @meta_keywords = @page.tag_list
    @meta_description = @page.page_description
    @related_guides = @page.related_guides
    @mod = @page.resource.mod if @page.resource
    @owner = @page.users.select{|u| u.name == @page.created_by}.first
    @updated = @page.updated_at.to_formatted_s(:long)
  end

  def published_pages
    @from = 'published'
    @meta_keywords = @local.ica_page_title + ", Course Guides, Research Topics, Library Help Guides"
    @meta_description = @local.ica_page_title + ". Library Help Guides for Course Assignments. "
    @title = @local.ica_page_title
    @pages = Page.get_published_pages
    @subjects = Subject.get_page_subjects(@pages)

    @campushash = Hash[*@campus.map{|a| a[0], a[1] = a[1], a[0]}.flatten]
    @campus.map{|a| a[0], a[1] = a[1], a[0]}
    @tags = Page.where(:published => true).tag_counts_on(:start_at => Time.now.prev_year, :order => 'taggings.created_at desc', :limit => 100)
  end

  def archived
    @meta_keywords = @local.ica_page_title + ", Course Guides, Research Topics, Library Help Guides, Archived"
    @meta_description = @local.ica_page_title + ". Archived Library Help Guides for Course Assignments."
    @title = @local.ica_page_title + " | Archived  "

    @subjects = Subject.get_subjects
    @pages = Page.get_archived_pages(nil)
    @tags = Page.where(:archived => true).tag_counts_on(:start_at => Time.now.prev_year, :order => 'taggings.created_at desc', :limit => 100)
    if request.post?
      if params[:subject]
        @subj = params[:subject]
        @subject = Subject.find(@subj)
        @pages = Page.get_archived_pages(@subject)
      end
    end
  end

  def tagged
    @tag = params[:id]
    @meta_keywords = @local.ica_page_title + ", " + @tag
    @meta_description =   @local.ica_page_title + ". Library Course Guides Tagged with: " + @tag
    @title = @local.ica_page_title + " | Tagged with: " + @tag
    @tags = Page.where(:published => true).tag_counts_on(:start_at => Time.now.prev_year, :order => 'taggings.created_at desc', :limit => 100)
    @pages = Page.tagged_with @tag
  end

  def feed
    @page = Page.find(params[:id])
    @mods = @page.recent_modules
    @page_url = url_for :controller => 'ica', :action => 'index', :id => @page
    @page_title = @page.header_title
    @page_description = @page.page_description
    author = @page.users.select{|u| u.name == @page.created_by}.first
    @author_email = author.email + " ("+author.name+")" if author
    response.headers['Content-Type'] = 'application/rss+xml'
    respond_to do |format|
      format.xml {render  :layout => false}
    end
  end
end
