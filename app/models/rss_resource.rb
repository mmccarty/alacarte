# == Schema Information
#
# Table name: rss_resources
#
#  id           :integer          not null, primary key
#  module_title :string(255)      default(""), not null
#  label        :string(255)
#  updated_at   :datetime
#  content_type :string(255)      default("RSS Feeds")
#  global       :boolean          default(FALSE)
#  created_by   :string(255)
#  information  :text
#  topic        :string(255)      default("")
#  num_feeds    :integer          default(6)
#  style        :string(255)      default("mixed")
#  slug         :string(255)
#  published    :boolean          default(FALSE)
#

class RssResource < ActiveRecord::Base
  include PolymorphicModule

  acts_as_taggable
  has_many :resources, :as => :mod,  :dependent => :destroy
  has_many :feeds, :dependent => :destroy
  before_create :private_label
  after_update :save_feeds

  validates :module_title, :presence => true
  validates :label, :presence => { :on => :update }

  def copy
    mod = PolymorphicModule::copy
    mod.feeds << feeds.map(&:clone).flatten
    mod
  end

  NUMFEEDS =  [["3",       3],
               ["6",       6],
               ["9",       9],
               ["15",      15]]

  def new_feed_attributes=(feed_attributes)
    feed_attributes.each do |attributes|
      feeds.build(attributes)
    end
  end

  def existing_feed_attributes=(feed_attributes)
    feeds.reject(&:new_record?).each do |feed|
      attributes = feed_attributes[feed.id.to_s]
      if attributes
        feed.attributes = attributes
      else
        feeds.delete(feed)
      end
    end
  end

  def feedurls
    feeds.collect {|f| f.url}
  end

  def feedlabels
    feeds.collect {|f| f.label}
  end

  def reader
    "http://www.google.com/jsapi?key="+GOOGLE_API
  end

  def save_feeds
    if feeds.present?
      feeds.each do |feed|
        feed.save
      end
    end
  end

  def rss_content
    self.information.present? ? self.information : ''
  end
end
