class LibResource < ActiveRecord::Base
  include HasResources

  acts_as_taggable
  has_many :resources, :as => :mod, :dependent => :destroy
  before_create :private_label
  validates_presence_of :module_title
  validates_format_of :email, :allow_nil => true, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :if => Proc.new {|c| not c.email.blank?}
  validates_presence_of :label, :on => :update

  def private_label
    self.label = self.module_title
  end

  def add_tags(tags)
    self.tag_list = tags
    self.save
  end

  def rss_content
    self.librarian_name.blank? ? "" : self.librarian_name
  end
end
