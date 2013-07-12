module PolymorphicModule
  extend ActiveSupport::Concern

  def private_label
    unless self.label
      self.label = self.module_title
    end
  end

  def add_tags(tags)
    self.tag_list = tags
    self.save
  end

  def shared?
    resources.any? { |r| r.users.length > 1 }
  end

  def used?
    resources.any? do |r|
      ! (r.tab_resources.empty? && r.pages.empty? && r.guides.empty? && r.resourceables.empty?)
    end
  end

  def get_guides
    get_resource_uses { |r| r.tabs.collect { |t| t.guide } }
  end

  def get_pages
    get_resource_uses { |r| r.tabs.collect { |t| t.page } }
  end

  def get_tutorials
    get_resource_uses { |r| r.units.collect { |t| t.tutorials } }
  end

  private

  def get_resource_uses(&block)
    resources.collect(&block).flatten.uniq.delete_if { |r| r.blank? }
  end
end
