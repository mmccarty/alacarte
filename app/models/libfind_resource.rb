class LibfindResource < ActiveRecord::Base
  include HasResources

  acts_as_taggable
  has_many :resources, :as => :mod, :dependent => :destroy
  has_many :lf_targets, :dependent => :delete_all
  before_create :private_label
  validates_presence_of :label, :on => :update

  validates_presence_of :module_title

  def private_label
    self.label = self.module_title
  end

  def add_tags(tags)
    self.tag_list = tags
    self.save
  end

  def add_lf_targets(targets)
    lf_targets.clear
    targets.each do |target|
      lf_targets << LfTarget.create(:value => target)
    end
  end

  def get_targets
    lf_targets.collect{|a| a.value}.join(",")
  end

  def rss_content
    self.information.blank? ? "" : self.information
  end

  def search
    "http://search.library.oregonstate.edu/record/retrieve"
  end
end
