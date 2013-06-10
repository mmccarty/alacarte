class CommentResource < ActiveRecord::Base
  acts_as_taggable
  has_many :resources, :as => :mod, :dependent => :destroy
  has_many :comments, :dependent => :delete_all

  before_create :private_label

  validates_presence_of :module_title
  validates_presence_of :label, :on => :update

  def private_label
    self.label = self.module_title
  end

  def add_tags(tags)
    self.tag_list = tags
    self.save
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

  def ordered_comments
    self.comments.find(:all, :limit => self.num_displayed, :order => "created_at DESC")
  end

  def more_comments
    self.comments.find(:all, :order => "created_at DESC")
  end

  def shared?
    self.resources.each do |r|
      return true if r.users.length > 1
    end
    return false
  end

  def rss_content
    return self.topic.blank? ? "" : self.topic
  end
end
