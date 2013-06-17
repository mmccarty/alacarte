class DatabaseResource < ActiveRecord::Base
  include HasResources

  acts_as_taggable
  has_many :resources, :as => :mod, :dependent => :destroy
  has_many :database_dods, :dependent => :destroy, :order => :location
  has_many :dods, :through => :database_dods

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

  def proxy
    Local.first.proxy
  end

  def add_dod(dod)
    db_dod = DatabaseDod.new(:dod_id => dod.id, :description => dod.descr, :location => self.database_dods.count+1)
    database_dods << db_dod
  end

  def rss_content
    self.info.blank? ? "" : self.info
  end
end
