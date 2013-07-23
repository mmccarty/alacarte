# == Schema Information
#
# Table name: reserve_resources
#
#  id               :integer          not null, primary key
#  module_title     :string(255)      default(""), not null
#  label            :string(255)
#  reserves         :text
#  library_reserves :text
#  course_title     :string(255)
#  updated_at       :datetime
#  content_type     :string(255)      default("Course Reserves")
#  global           :boolean          default(FALSE)
#  created_by       :string(255)
#  slug             :string(255)
#  published        :boolean          default(FALSE)
#

class ReserveResource < ActiveRecord::Base
  include PolymorphicModule

  acts_as_taggable
  before_create :private_label
  serialize :library_reserves

  validates :module_title, :presence => true
  validates :label, :presence => { :on => :update }

  def after_create
    self.library_reserves = []
    self.save
  end

  def rss_content
    self.reserves.present? ? self.reserves : ''
  end
end
