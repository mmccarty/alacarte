# == Schema Information
#
# Table name: nodes
#
#  id           :integer          not null, primary key
#  module_title :string(255)      default(""), not null
#  label        :string(255)
#  content      :text
#  more_info    :text
#  created_by   :string(255)
#  updated_at   :datetime
#  global       :boolean          default(FALSE)
#  slug         :string(255)
#  published    :boolean          default(FALSE)
#

class Node < ActiveRecord::Base
  acts_as_taggable
  before_create :private_label

  has_many :guides
  has_many :pages
  has_many :users

  has_and_belongs_to_many :tabs, join_table: 'tab_nodes'

  validates :module_title, presence: true
  validates :label, presence: { on: :update }

  searchable do
    text :module_title, :label, :content, :more_info
  end

  # Alias to help us through the conversion.
  def mod
    self
  end

  # Alias to help us through the conversion.
  def resource
    self
  end

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
    users.length > 1
  end

  def used?
    ! (guides.empty? && pages.empty? && tabs.empty? && users.empty?)
  end

  def get_guides
    tabs.map &:guide
  end

  def get_pages
    tabs.map &:page
  end

  def create_slug trunc = 25, truncate_string = '...'
    l = trunc - truncate_string.mb_chars.length
    chars = label.mb_chars
    self.slug = (chars.length > trunc ? chars[0...l] + truncate_string : chars).to_s
    self.save
  end
end
