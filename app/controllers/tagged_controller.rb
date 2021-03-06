class TaggedController < ApplicationController
  layout 'admin'

  def index
    set_node_variables(params[:all],params[:tag],params[:sort])
    @tgcurrent = 'current'
    @tags = @user.node_tags
    @mods = @tag == "" ?  @user.sort_mods(@sort) : @user.find_mods_tagged_with(@tag)
    @mods = @mods.paginate page: params[:page]
    if request.xhr?
      render :partial => "tag_list", :layout => false
    end
  end

  def set_node_variables(all,tag,sort)
    @mcurrent = 'current'
    @all = all || 'all'
    @tag = tag || ""
    @sort = sort || 'name'
  end
end
