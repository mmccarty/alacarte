# == Schema Information
#
# Table name: database_resources
#
#  id           :integer          not null, primary key
#  created_by   :string(255)
#  updated_at   :datetime
#  module_title :string(255)      default(""), not null
#  global       :boolean          default(FALSE)
#  content_type :string(255)      default("Databases")
#  label        :string(255)
#  info         :text
#  slug         :string(255)
#  published    :boolean          default(FALSE)
#

class DatabaseResource < ActiveRecord::Base
  include PolymorphicModule

  acts_as_taggable
  has_many :resources, :as => :mod, :dependent => :destroy
  has_many :database_dods, :dependent => :destroy, :order => :location
  has_many :dods, :through => :database_dods

  before_create :private_label

  validates :module_title, :presence => true
  validates :label, :presence => { :on => :update }

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
