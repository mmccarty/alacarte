# == Schema Information
#
# Table name: url_resources
#
#  id            :integer          not null, primary key
#  module_title  :string(255)      default(""), not null
#  label         :string(255)
#  updated_at    :datetime
#  content_type  :string(255)      default("Web Links")
#  global        :boolean          default(FALSE)
#  created_by    :string(255)
#  created_by_id :integer
#  information   :text
#  slug          :string(255)
#  published     :boolean          default(FALSE)
#

class UrlResource < ActiveRecord::Base
  include PolymorphicModule

  acts_as_taggable
  has_many :resources, :as => :mod,  :dependent => :destroy
  has_many :links, :dependent => :destroy
  before_create :private_label

  validates :module_title, :presence => true
  validates :label, :presence => {:on => :update}

  def copy
    mod = PolymorphicModule::copy
    mod.links << links.map(&:clone)
    mod
  end

  def rss_content
    self.information.present? ? self.information : ''
  end
end
