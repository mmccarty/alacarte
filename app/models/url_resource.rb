class UrlResource < ActiveRecord::Base
  acts_as_taggable
  has_many :resources, :as => :mod,  :dependent => :destroy
  has_many :links, :order => :position, :dependent => :destroy
  before_create :private_label
  before_save :save_links

  validates_presence_of :module_title
  validates_presence_of :label, :on => :update

  def private_label
    self.label = self.module_title
  end

  def new_link_attributes=(link_attributes)
    logger.info "Link Attributes: #{link_attributes.inspect}"
    newattributes = []
    link_attributes.each do |key, value|
      value["label"] = ""
      newattributes.push value
    end
    logger.info "Link Attributes: #{newattributes.inspect}"
    newattributes.each do |attributes|
      links.build(attributes)
    end
  end

  def existing_link_attributes=(link_attributes)
    links.reject(&:new_record?).each do |link|
      attributes = link_attributes[link.id.to_s]
      if attributes
        link.attributes = attributes
      else
        links.delete(link)
      end
    end
  end

  def save_links
    links.each do |link|
      link.id = nil if link.new_record?
      link.save(true)
    end
  end

  def used?
    self.resources.each do |r|
      return false if r.tab_resources.length < 1 and  r.pages.length < 1 and r.guides.length < 1 and r.resourceables.length < 1
    end
    return true
  end

  def get_pages
    return  resources.collect{|r| r.tabs.collect{|t| t.page}}.flatten.uniq.delete_if{|p| p.blank?}
  end

  def get_guides
    return  resources.collect{|r| r.tabs.collect{|t| t.guide}}.flatten.uniq.delete_if{|p| p.blank?}
  end

  def get_tutorials
    return  resources.collect{|r| r.units.collect{|t| t.tutorials}}.flatten.uniq.delete_if{|p| p.blank?}
  end

  def rss_content
    return self.information.blank? ? "" : self.information
  end

  def add_tags(tags)
    self.tag_list = tags
    self.save
  end

  def shared?
    self.resources.each do |r|
      return true if r.users.length > 1
    end
    return false
  end
end
