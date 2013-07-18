# == Schema Information
#
# Table name: units
#
#  id          :integer          not null, primary key
#  title       :string(255)      not null
#  description :text
#  created_by  :integer
#  updated_at  :datetime
#  slug        :string(255)      default("")
#

class Unit < ActiveRecord::Base
  include HasModules

  acts_as_taggable
  has_many :unitizations, :dependent => :destroy
  has_many :tutorials, :through => :unitizations
  has_many :resources, :through => :resourceables
  has_many :resourceables, :order => :position, :dependent => :destroy

  validates_presence_of  :title
  validates_presence_of  :slug, :on => :update
  validates_length_of :slug, :maximum=>15, :message=>"less than {{count}}", :on => :update
  before_create :create_slug

  # Required by HasModules concern.
  def update_users
  end

  def create_slug trunc = 15, truncate_string = "..."
    text = self.title
    l = trunc - truncate_string.mb_chars.length
    chars = text.mb_chars
    self.slug = (chars.length > trunc ? chars[0...l] + truncate_string : text).to_s
  end

  def sorted_resources
    resourceables.map &:resource
  end

  def first_module
    res = sorted_resources.first
    res.blank? ? nil : res.mod
  end

  def last_module
    res = sorted_resources.last
    res.blank? ? nil : res.mod
  end

  def next_module id, type
    res = find_resource id, type
    resable = resourceables.select { |r| r.resource.id == res.id }.first
    next_resable = resable.lower_item
    next_resable.blank? ? nil : next_resable.resource.mod
  end

  def prev_module id, type
    res = find_resource id, type
    resable = resourceables.select { |r| r.resource.id == res.id }.first
    prev_resable = resable.higher_item
    prev_resable.blank? ? nil : prev_resable.resource.mod
  end
end
