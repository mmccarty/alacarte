module HasResources
  extend ActiveSupport::Concern

  def shared?
    self.resources.any { |r| r.users.length > 1 }
  end

  def used?
    not resources.any do |r|
      r.tab_resources.length > 0 || r.pages.length > 0 || r.guides.length > 0 || r.resourceables.length > 0
    end
  end

  def get_pages
    self.get_nested_resources { |r| r.tabs.collect { |t| t.page } }
  end

  def get_guides
    self.get_nested_resources { |r| r.tabs.collect { |t| t.guide } }
  end

  def get_tutorials
    self.get_nested_resources { |r| r.units.collect { |t| t.tutorials } }
  end

  private

  def get_nested_resources(&block)
    resources.collect(&block).flatten.uniq.delete_if { |r| r.blank? }
  end
end
