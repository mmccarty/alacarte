class CommentResource < ActiveRecord::Base
  include HasResources

  acts_as_taggable
  has_many :resources, :as => :mod, :dependent => :destroy
  has_many :comments, :dependent => :delete_all

  before_create :private_label

  validates :module_title, :presence => true
  validates :label, :presence => { :on => :update }

  def private_label
    self.label = self.module_title
  end

  def add_tags(tags)
    self.tag_list = tags
    self.save
  end

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
