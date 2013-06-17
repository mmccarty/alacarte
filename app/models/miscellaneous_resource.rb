class MiscellaneousResource < ActiveRecord::Base
  include HasResources

  acts_as_taggable
  has_many :resources, :as => :mod,  :dependent => :destroy
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

  def rss_content
    self.content.blank? ? "" : self.content
  end
end
