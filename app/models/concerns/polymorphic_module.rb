module PolymorphicModule
  extend ActiveSupport::Concern

  def add_tags tags
    self.tag_list = tags
    self.save
  end

  def copy
    mod = dup
    mod.label  = "#{ label }-copy"
    mod.global = false
    mod
  end

  def private_label
    self.label ||= self.module_title
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
    get_resource_uses { |r| r.tabs.map &:guide }
  end

  def get_pages
    get_resource_uses { |r| r.tabs.map &:page }
  end

  private

  def get_resource_uses(&block)
    resources.map(&block).flatten.uniq.delete_if &:blank?
  end
end
