module ItsJustAPage
  extend ActiveSupport::Concern

  def add_tags tags
    self.tag_list = tags
    self.save
  end

  def add_tab tab
    tabs << tab
  end

  def reached_limit?
    tabs.length > 6
  end

  def modules
    tabs.flat_map &:modules
  end

  def recent_modules
    tabs.flat_map &:recent_modules
  end

  def shared?
    users.length > 1
  end

  def add_user user
    users << user
  end

  def update_users
    tabs.flat_map(&:resources).each do |resource|
      users.each do |user|
        user.add_resource(resource) unless(user.id == @user || user.resources.include?(resource) == true)
      end
    end
  end

  def share uid, copy
    user = User.find uid
    if copy == '1'
      share_copy user
    else
      users << user
      tabs.flat_map(&:resources).each { |resource| user.add_resource resource }
    end
  end

  def copy_resources uid, tbs
    # Need an id to add tabs
    save
    tabs.destroy_all
    reload
    user = User.find uid
    tbs.each do |tab|
      mod_copies = tab.tab_resources.flat_map { |r| r.resource.copy_mod(tab.page.route_title) }
      tab_copy = tab.dup
      if tab_copy.save
        mod_copies.each do |mod|
          mod.update_attribute :created_by, user.name
          resource = Resource.create mod: mod
          user.add_resource resource
          tab_copy.add_resource resource
        end
        add_tab tab_copy
      end
    end
  end

  def copy_tabs tbs
    # Need an id to add tabs
    save
    tabs.destroy_all
    reload
    tbs.each do |tab|
      tab_copy = tab.dup
      if tab_copy.save
        tab.tab_resources.each do |res|
          tab_copy.add_resource res.resource
        end
        add_tab tab_copy
      end
    end
  end

  # Defaults related guides on creation.
  def create_relateds
    update_attribute :relateds, get_related_guides
  end

  def delete_relateds id
    relateds.delete id.to_i
    save
  end

  def add_related_guides ids
    ids.each do |id|
      relateds << id.to_i unless relateds.include? id.to_i
    end
  end

  # Return a safe list of related guides.
  def related_guides
    guides = []
    if relateds == nil
      create_relateds
    end
    relateds.each do |id|
      if Guide.exists? id.to_i
        guide = Guide.find id.to_i
        if guide.published?
          guides << guide
        else
          relateds.delete id.to_i
        end
      else
        relateds.delete id.to_i
      end
    end
    guides.sort_by { |x| x.guide_name.downcase }
  end

  # Defines the list of related guides to be those suggested by master subject.
  def suggested_relateds
    add_related_guides get_related_guides
    save
    related_guides
  end
end
