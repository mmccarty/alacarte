class BookController < ApplicationController
  include CatalogScraper
  layout 'admin'

  def copy
    old_mod = BookResource.find params[:id]
    @new_mod = old_mod.dup
    if @new_mod.save
      create_and_add_resource @user, @new_mod
      redirect_to action: :edit_book, id: @new_mod.id
    end
  end

  def retrieve_results
    @mod = find_mod(params[:id], "BookResource")
    if request.xhr?
      #The scraper just wants the URI, not the entire html link tag.
      /href="(.*)"/.match(params[:title])
      link = $1 if $1
      if link
        results = search_catalog(nil, link)
        #we have to put the reserves somewhere "safe" across the AJAX request
        #so we tuck it into the session, and then erase it when we are done
        #saving our changes to the module
        @result = session[:results] = results
        @title = params[:title].scan(/\>(.*?)\</)
      end
      render :partial => "book/catalog_title", :locals => {:results => results, :mod =>@mod} and return
    end
    redirect_to :back
  end

  def edit_book
    @ecurrent = 'current'
    begin
      @mod = find_mod(params[:id], "BookResource")
    rescue ActiveRecord::RecordNotFound
      redirect_to :controller => 'module', :action => 'index', :list=> 'mine'
    else
      @tags = @mod.tag_list
      session[:mod_id] = @mod.id
      session[:mod_type] = @mod.class
    end
  end

  def save_book
    @mod = find_mod(params[:id], "BookResource")
    image =  params[:isbn] ? params[:isbn].scan(/^(.*?)\s/) : ""
    new = Book.new(:url => 'http://',:image_id => image.to_s,  :catalog_results => params[:results])
    @mod.books << new
    render :partial => "book/book", :collection => @mod.books, :locals => {:mod =>@mod} and return
  end

  def update_book
    params[:mod][:existing_book_attributes] ||= {}
    params[:mod][:new_book_attributes] ||= {}
    @mod = find_mod(params[:id], "BookResource")
    @mod.update_attributes(params[:mod])
    if @mod.save
      @mod.add_tags(params[:tags]) if params[:tags]
      redirect_to :controller => 'module', :action => "preview" , :id =>@mod.id, :type=> @mod.class
    else
      render :action => 'edit_book' , :mod => @mod
    end
  end
end
