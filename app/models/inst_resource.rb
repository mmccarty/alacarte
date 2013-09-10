# == Schema Information
#
# Table name: inst_resources
#
#  id              :integer          not null, primary key
#  module_title    :string(255)      default(""), not null
#  label           :string(255)
#  instructor_name :string(255)
#  email           :string(255)
#  office_location :string(255)
#  office_hours    :string(255)
#  website         :string(255)
#  updated_at      :datetime
#  content_type    :string(255)      default("Instructor Profile")
#  global          :boolean          default(FALSE)
#  created_by      :string(255)
#  slug            :string(255)
#  published       :boolean          default(FALSE)
#

class InstResource < ActiveRecord::Base
  include PolymorphicModule

  acts_as_taggable
  has_many :resources, :as => :mod, :dependent => :destroy
  before_create :private_label

  validates :module_title, :presence => true
  validates :email, format: {with: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, if: Proc.new {|c| not c.email.blank?}}
  validates :website, format: {with: /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix, if: Proc.new {|c| not c.website.blank?}, message: 'URL must be valid and begin with http or https.'}
  validates :label, :presence => { :on => :update }

  searchable do
    text :module_title, :label, :instructor_name
  end

  def rss_content
    self.instructor_name.present? ? self.instructor_name : ''
  end
end
