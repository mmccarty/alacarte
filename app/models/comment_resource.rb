# == Schema Information
#
# Table name: comment_resources
#
#  id            :integer          not null, primary key
#  module_title  :string(255)      default(""), not null
#  label         :string(255)
#  topic         :text
#  num_displayed :integer          default(3)
#  updated_at    :datetime
#  content_type  :string(255)      default("Comments")
#  global        :boolean          default(FALSE)
#  created_by    :string(255)
#  slug          :string(255)
#  published     :boolean          default(FALSE)
#

class CommentResource < ActiveRecord::Base
  include PolymorphicModule

  acts_as_taggable
  has_many :resources, :as => :mod, :dependent => :destroy
  has_many :comments, :dependent => :delete_all

  before_create :private_label

  validates :module_title, :presence => true
  validates :label, :presence => { :on => :update }

  def ordered_comments
    self.comments.limit(self.num_displayed).order("created_at DESC")
  end

  def more_comments
    self.comments.order("created_at DESC")
  end

  def rss_content
    self.topic.blank? ? "" : self.topic
  end
end
