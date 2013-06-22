module ApplicationHelper
  def show_mod(mod)
    if !mod.blank?
      @mod = mod
      mod_class = @mod.class.to_s
      render :partial => 'shared/'+mod_class.underscore+'_module.html', :object => @mod
    end
  end

  def new_button(text)
    render :partial => 'shared/new_button', :locals => { :text => text }
  end

  def show_form(mod_type)
    render :partial => 'module/'+mod_type.underscore+'_form'
  end

  def render_tooltip(mod)
    tooltip =""
    tooltip += "Title: " + h(mod.module_title) + "<br />"
    tooltip += "Label: " + h(mod.label) + "<br />"
    tooltip += "Last Update: " + mod.updated_at.to_date.to_s + "<br />"
    tooltip += "Shared? " + (mod.shared? == false ? "Yes" : "No") + "<br />"
    tooltip += "In Use? " + (mod.used? == false ? "No" : "Yes") + "<br />"
    tooltip
  end

  def render_used_tooltip(mod)
    pages = mod.get_pages.collect{|p| h(p.header_title)}
    guides = mod.get_guides.collect{|p| h(p.guide_name)}
    tutorials = mod.get_tutorials.collect{|p| h(p.full_name)}
    tip = ""
    tip += "<strong>" + h(mod.module_title).gsub(/'/, "\\\\'") + " is used on</strong> <br />"
    tip += "<strong>Pages: </strong>" + pages.to_sentence + "<br />" unless pages.length < 1 == true
    tip += "<strong>Guides: </strong>" + guides.to_sentence + "<br />" unless guides.length < 1 == true
    tip += "<strong>Tutorials: </strong>" + tutorials.to_sentence + "<br />" unless tutorials.length < 1 == true
    tip += "<strong>A Default Contact Module</strong>" + "<br />" unless @user.get_profile.blank? or @user.get_profile.id != mod.id
    tip += "<strong>A Contact Module</strong>" + "<br />" if tip == ("<strong>" + h(mod.module_title).gsub(/'/, "\\\\'") + " is used on</strong> <br />")
    tip +  "Click to manage this module."
  end

  def sort_th_class_helper(param)
    result = "sortup" if @sort == param
    result = "sortdown" if @sort == param + "_reverse"
    result
  end

  def sort_link_helper(text, param)
    key = param
    key += "_reverse" if params[:sort] == param
    options = {
      :update => 'table',
      :loading => "Element.show('spinner_sort')",
      :complete => "Element.hide('spinner_sort')",
      :url => {:action => 'index',:params => params.merge({:sort => key, :page => nil})}
    }
    html_options = {
      :title => "Sort by this field",
      :href => url_for(:action => 'index', :params => params.merge({:sort => key, :page => nil}))
    }
    link_to(text, options, html_options, :remote => true)
  end

  def sort_links(sort)
    options = {
      :update => 'a_z_list',
      :loading => "Element.show('spinner_sort')",
      :complete => "Element.hide('spinner_sort')",
      :url => {:action => 'edit_databases', :params => params.merge({:sort => sort})}
    }
    html_options = {
      :title => "view databases the begin with this letter"
    }
    link_to(sort, options, html_options, :remote => true)
  end

  def related_link
    options = {
      :update => 'suggestions',
      :loading => "Element.show('spinner_sort')",
      :complete => "Element.hide('spinner_sort')",
      :url => {:action => 'suggest_relateds'}
    }
    html_options = {
      :title => "Click to automatically find related guides"
    }
    link_to("Automatically Add Related Guides", options, html_options, :remote => true)
  end

  def set_owner_helper(id, uid)
    options = {
      :update => 'editor-list',
      :loading => "Element.show('spinner_sort')",
      :complete => "Element.hide('spinner_sort')",
      :url => { :action => 'set_owner', :id => id, :uid => uid}
    }
    html_options = {
      :title => "Make this user the guide owner",
      :href => url_for({:controller =>'guide', :action => 'set_owner', :id => id, :uid => uid})
    }
    link_to("Make Owner", options, html_options, :remote => true)
  end

  def truncate_comment(comment, num_characters)
    comment_copy = ""
    comment_size = 0

    h(comment).each(" ") do |w|
      if comment_size + w.size > num_characters
        break
      else
        comment_size += w.size
        comment_copy += " #{w}"
      end
    end

    first_newline = comment_copy[0..(num_characters - 1)].index("\n")

    if first_newline and comment.size != num_characters
      comment_copy = comment_copy[0..(first_newline - 1)] + "..."
    elsif comment.size > comment_size
      comment_copy += "..."
    end

    simple_format(comment_copy)
  end

  def checked?(val)
    targets = @mod.lf_targets.collect{|a| a.value}
    targets.include?(val)
  end

  def is_more?
    @mod.more_info.blank?
  end
end
