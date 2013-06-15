class ReserveResource < ActiveRecord::Base
  include HasResources

  acts_as_taggable
  has_many :resources, :as => :mod,  :dependent => :destroy
  before_create :private_label
  serialize :library_reserves

  validates_presence_of :module_title
  validates_presence_of :label, :on => :update

  def private_label
    self.label = self.module_title
  end

  def add_tags(tags)
    self.tag_list = tags
    self.save
  end

  def after_create
    self.library_reserves = []
    self.save
  end

  def rss_content
    self.reserves.blank? ? "" : self.reserves
  end
end
