class LinksController < ApplicationController
  before_filter :authorize_admin
  before_filter :find_url_resource
  layout 'admin'

  def new
    @link = Link.new
  end

  def create
    @link = Link.create params[:link]
    if @link.save
      @url_resource.links << @link
      redirect_to edit_url_resource_path @link.url_resource
    else
      render :new
    end

  end

  def edit
    @link = Link.find params[:id]
  end

  def update
    @link = Link.find params[:id]
    @link.update_attributes params[:link]
    if @link
      redirect_to edit_url_resource_path @link.url_resource
    else
      render :edit, id: @link.id
    end
  end

  def destroy
    link = Link.find params[:id]
    link.destroy
    flash[:notice] = "Link successfully deleted."
    redirect_to edit_url_resource_path link.url_resource
  end

  def find_url_resource
    @url_resource = UrlResource.find params[:url_resource_id] if params[:url_resource_id]
  end
end