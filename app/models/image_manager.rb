# == Schema Information
#
# Table name: image_managers
#
#  id                 :integer          not null, primary key
#  created_at         :datetime
#  updated_at         :datetime
#  photo_file_name    :string(255)
#  photo_content_type :string(255)
#  photo_file_size    :integer
#  photo_updated_at   :datetime
#

class ImageManager < ActiveRecord::Base
  has_attached_file :photo,
  :styles => { :original => '505x425>', :thumb => '75x75>' },
  :url => "/photos/:attachment/:style/:basename.:extension",
  :path => ":rails_root/public/photos/:attachment/:style/:basename.:extension"

  validates_presence_of :photo_file_name, :message => _('File name can not be blank')
  validates_uniqueness_of :photo_file_name, :message => _('That photo has already been uploaded')
  validates_attachment_size :photo, :less_than => 5.megabytes, :message => _('File size must be less than 5 MB')

  validates_attachment_content_type :photo,
  :content_type => ['image/jpg', 'image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png', 'image/bmp'],
  :message => _('Only .jpg, .jpeg, .pjpeg, .gif, .png, .x-png and .bmp files are allowed')
end
