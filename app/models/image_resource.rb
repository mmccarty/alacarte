# == Schema Information
#
# Table name: image_resources
#
#  id           :integer          not null, primary key
#  module_title :string(255)      not null
#  label        :string(255)
#  created_by   :string(255)
#  updated_at   :datetime
#  information  :text
#  global       :boolean          default(FALSE)
#  content_type :string(255)      default("Images")
#  slug         :string(255)
#  size         :string(255)      default("F")
#  orientation  :string(255)      default("V")
#  published    :boolean          default(FALSE)
#

class ImageResource < ActiveRecord::Base
  include PolymorphicModule

  acts_as_taggable
  has_many :resources, :as => :mod,  :dependent => :destroy
  has_many :images,  :dependent => :destroy
  before_create :private_label
  after_update :save_images

  validates :module_title, :presence => true
  validates :label, :presence => { :on => :update }

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
end
