class Image < ActiveRecord::Base
  belongs_to :image_resource
  validates :url, :format => { :with => URI::regexp(%w(http https)) }
end
