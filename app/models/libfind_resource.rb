# == Schema Information
#
# Table name: libfind_resources
#
#  id           :integer          not null, primary key
#  module_title :string(255)      default(""), not null
#  label        :string(255)
#  information  :text
#  updated_at   :datetime
#  content_type :string(255)      default("LibraryFind Search")
#  global       :boolean          default(FALSE)
#  created_by   :string(255)
#  slug         :string(255)
#  published    :boolean          default(FALSE)
#

class LibfindResource < ActiveRecord::Base
  include PolymorphicModule

  acts_as_taggable
  has_many :resources, :as => :mod, :dependent => :destroy
  has_many :lf_targets, :dependent => :delete_all
  before_create :private_label

  validates :label, :presence => { :on => :update }
  validates :module_title, :presence => true

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
end
