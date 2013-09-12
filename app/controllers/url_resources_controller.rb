class UrlResourcesController < ApplicationController
  before_filter :module_types
  layout 'admin'

  def show
    @mod = UrlResource.find params[:id]
  end

  def edit
    @mod = UrlResource.find params[:id]
    @link = Link.new
  end

  def update
    @mod = UrlResource.find params[:id]
    @mod.update_attributes url_resource_params
    if @mod.save
      redirect_to @mod
    else
      render :edit, id: @mod.id
    end
  end

  def copy
    old_mod = UrlResource.find params[:id]
    @new_mod = old_mod.dup
    if @new_mod.save
      create_and_add_resource @user, @new_mod
      redirect_to edit_url_resource_path @new_mod
    end
  end

  def reorder_links
    if params['link_ids']
      ordered_links = params['link_ids']
      ordered_links.each do |id|
        link = Link.find id
        link.update_attribute(:position, ordered_links.index(id) + 1)
      end
    end
    render :nothing => true
  end

  private

  def url_resource_params
    params.require(:url_resource).permit :module_title, :label
  end
end
