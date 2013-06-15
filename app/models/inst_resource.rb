class InstResource < ActiveRecord::Base
  include HasResource

  acts_as_taggable
  has_many :resources, :as => :mod, :dependent => :destroy
  before_create :private_label

  validates_presence_of :module_title
  validates_format_of :email,:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :if => Proc.new {|c| not c.email.blank?}
  validates_format_of :website,:with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix, :if => Proc.new {|c| not c.website.blank?}, :message => 'URL must be valid and begin with http or https.'
  validates_presence_of :label, :on => :update

  def private_label
    self.label = self.module_title
  end

  def rss_content
    self.instructor_name.blank? ? "" : self.instructor_name
  end

  def add_tags(tags)
    self.tag_list = tags
    self.save
  end
end
