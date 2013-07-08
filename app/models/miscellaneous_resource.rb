# == Schema Information
#
# Table name: miscellaneous_resources
#
#  id           :integer          not null, primary key
#  module_title :string(255)      default(""), not null
#  label        :string(255)
#  content      :text
#  more_info    :text
#  created_by   :string(255)
#  updated_at   :datetime
#  global       :boolean          default(FALSE)
#  content_type :string(255)      default("Custom Content")
#  slug         :string(255)
#  published    :boolean          default(FALSE)
#

class MiscellaneousResource < ActiveRecord::Base
  include HasResources

  acts_as_taggable
  has_many :resources, as: :mod,  dependent: :destroy
  before_create :private_label

  validates :module_title, presence: true
  validates :label, presence: { on: :update }

  def private_label
    self.label = self.module_title
  end

  def add_tags(tags)
    self.tag_list = tags
    self.save
  end

  def rss_content
    self.content.blank? ? '' : self.content
  end
end
