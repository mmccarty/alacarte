class UploaderResource < ActiveRecord::Base
  include HasResources

  acts_as_taggable
  has_many :resources, :as => :mod, :dependent => :destroy
  has_many :uploadables
  before_create :private_label
  after_update :save_uploadables

  attr_protected :upload_file_name, :upload_content_type, :upload_size
  validates_presence_of :module_title
  validates_presence_of :label, :on => :update

  def private_label
    self.label = self.module_title
  end

  def add_tags(tags)
    self.tag_list = tags
    self.save
  end

  def rss_content
    self.info.blank? ? "" : self.info
  end

  def new_uploadable_attributes=(uploadable_attributes)
    uploadable_attributes.each do |attributes|
      uploadables.build(attributes)
    end
  end

  def existing_uploadable_attributes=(uploadable_attributes)
    uploadables.reject(&:new_record?).each do |uploadable|
      attributes = uploadable_attributes[uploadable.id.to_s]
      if attributes
        uploadable.attributes = attributes
      else
        uploadables.delete(uploadable)
      end
    end
  end

  def save_uploadables
    uploadables.each do |uploadable|
      uploadable.save(false)
    end
  end
end
