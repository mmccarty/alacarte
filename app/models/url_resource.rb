# == Schema Information
#
# Table name: url_resources
#
#  id            :integer          not null, primary key
#  module_title  :string(255)      default(""), not null
#  label         :string(255)
#  updated_at    :datetime
#  content_type  :string(255)      default("Web Links")
#  global        :boolean          default(FALSE)
#  created_by    :string(255)
#  created_by_id :integer
#  information   :text
#  slug          :string(255)
#  published     :boolean          default(FALSE)
#

class UrlResource < ActiveRecord::Base
  include HasResources

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

  def rss_content
    self.information.blank? ? "" : self.information
  end

  def add_tags(tags)
    self.tag_list = tags
    self.save
  end
end
