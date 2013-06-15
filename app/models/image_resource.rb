class ImageResource < ActiveRecord::Base
  include HasResources

  acts_as_taggable
  has_many :resources, :as => :mod,  :dependent => :destroy
  has_many :images,  :dependent => :destroy
  before_create :private_label
  after_update :save_images

  validates_presence_of :module_title
  validates_presence_of :label, :on => :update

  def private_label
    self.label = self.module_title
  end

  #converts sizes to flickr sub-strings
  def fk_size
    case size
    when "Q" then return "_s.jpg"
    when "S" then return "_m.jpg"
    when "T" then return "_t.jpg"
    else
      return ".jpg"
    end
  end

  def new_image_attributes=(image_attributes)
    image_attributes.each do |attributes|
      images.build(attributes)
    end
  end

  def existing_image_attributes=(image_attributes)
    images.reject(&:new_record?).each do |image|
      attributes = image_attributes[image.id.to_s]
      if attributes
        image.attributes = attributes
      else
        images.delete(image)
      end
    end
  end

  def save_images
    images.each do |image|
      image.save(false)
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
