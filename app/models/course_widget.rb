# == Schema Information
#
# Table name: course_widgets
#
#  id           :integer          not null, primary key
#  module_title :string(255)      default(""), not null
#  label        :string(255)
#  widget       :text
#  information  :text
#  updated_at   :datetime
#  content_type :string(255)      default("Multi-Media Widget")
#  global       :boolean          default(FALSE)
#  created_by   :string(255)
#  slug         :string(255)
#  published    :boolean          default(FALSE)
#

class CourseWidget < ActiveRecord::Base
  include PolymorphicModule

  acts_as_taggable
  has_many :resources, :as => :mod,  :dependent => :destroy

  before_create :private_label

  validates :module_title, :presence => true
  validates :label, :presence => { :on => :update }

  def rss_content
    self.information.blank? ? '' : self.information
  end
end
