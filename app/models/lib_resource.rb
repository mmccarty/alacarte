# == Schema Information
#
# Table name: lib_resources
#
#  id              :integer          not null, primary key
#  module_title    :string(255)      default(""), not null
#  label           :string(255)
#  librarian_name  :string(255)
#  email           :string(255)
#  chat_info       :string(255)
#  office_hours    :string(255)
#  office_location :string(255)
#  chat_widget     :text
#  updated_at      :datetime
#  content_type    :string(255)      default("Librarian Profile")
#  global          :boolean          default(FALSE)
#  created_by      :string(255)
#  image_info      :text
#  slug            :string(255)
#  published       :boolean          default(FALSE)
#

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
