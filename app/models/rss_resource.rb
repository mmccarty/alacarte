class RssResource < ActiveRecord::Base
  include HasResources

  acts_as_taggable
  has_many :resources, :as => :mod,  :dependent => :destroy
  has_many :feeds, :dependent => :destroy
  before_create :private_label
  after_update :save_feeds

  validates :module_title, :presence => true
  validates :label, :presence => { :on => :update }

  NUMFEEDS =  [
               ["3",       3],
               ["6",       6],
               ["9",       9],
               ["15",      15],
              ]

  def private_label
    self.label = self.module_title
  end

  def add_tags(tags)
    self.tag_list = tags
    self.save
  end

  def rss_content
    self.information.blank? ? "" : self.information
  end

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
    if !feeds.blank?
      feeds.each do |feed|
        feed.save(false)
      end
    end
  end
end
