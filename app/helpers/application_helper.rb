module ApplicationHelper
  # awesome button is awesome
  def awesome_button(url, icon, text = '', style = '')
    if style.match 'btn'
      html = "<i class='icon-#{ icon }'></i>&nbsp; #{ text }"
      link_to html.html_safe, url, class: style
    else
      link_to '', url, class: "icon-#{ icon } #{ style }", title: text
    end
  end

  def icon_tag(name, title = '')
    html = "<i class='icon-#{ name }' title='#{ title }'></i>"
    html.html_safe
  end

  def new_button(text)
    link_to text, { :action => :new }, :class => 'btn'
  end

  def flash_notice
    render 'shared/flash_notice'
  end

  def more_help(msg, width)
    render :partial => 'shared/more_help', :locals => { :msg => msg, :width => width }
  end

  def related_link
    options = {
      :update => 'suggestions',
      :loading => "Element.show('spinner_sort')",
      :complete => "Element.hide('spinner_sort')",
      :url => { :action => 'suggest_relateds' }
    }
    html_options = {
      :title => "Click to automatically find related guides"
    }
    link_to "Automatically Add Related Guides", options, html_options, :remote => true
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

  def report_errors(obj)
    render :partial => 'shared/report_errors', :locals => { :object => obj }
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
    ! @mod.more_info.blank?
  end
end
