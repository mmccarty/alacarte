class VideoResource < ActiveRecord::Base
  include HasResources

  acts_as_taggable
  has_many :resources, :as => :mod,  :dependent => :destroy
  has_many :videos, :order => :position,  :dependent => :destroy
  before_create :private_label
  after_update :save_videos
  #require 'active_youtube'

  validates_presence_of :module_title
  validates_presence_of :label, :on => :update

  def private_label
    self.label = self.module_title
  end

  def new_video_attributes=(video_attributes)
    video_attributes.each do |attributes|
      videos.build(attributes)
    end
  end

  def existing_video_attributes=(video_attributes)
    videos.reject(&:new_record?).each do |video|
      attributes = video_attributes[video.id.to_s]
      if attributes
        video.attributes = attributes
      else
        videos.delete(video)
      end
    end
  end

  def save_videos
    videos.each do |video|
      video.save(false)
    end
  end

  def rss_content
    self.information.blank? ? "" : self.information
  end

  def add_tags(tags)
    self.tag_list = tags
    self.save
  end
end
