# == Schema Information
#
# Table name: images
#
#  id                :integer          not null, primary key
#  image_resource_id :integer
#  url               :string(255)
#  description       :text
#  alt               :string(255)
#  position          :integer
#

class Image < ActiveRecord::Base
  belongs_to :image_resource
  validates :url, :format => { :with => URI::regexp(%w(http https)) }
end
