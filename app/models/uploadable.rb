# == Schema Information
#
# Table name: uploadables
#
#  id                   :integer          not null, primary key
#  upload_file_name     :string(255)
#  upload_content_type  :string(255)
#  upload_file_size     :integer
#  upload_updated_at    :datetime
#  uploader_resource_id :integer
#  upload_info          :text
#  upload_link          :string(255)
#

class Uploadable < ActiveRecord::Base
  belongs_to :uploader_resource
  has_attached_file :upload,
  :styles => { :medium => '505x405>', :thumb => '75x75>' },
  :url => "/uploads/:attachment/:style/:basename.:extension",
  :path => ":rails_root/public/uploads/:attachment/:style/:basename.:extension"

  def logo
    if upload_content_type == 'application/pdf'
      return  logo_image = "icons/pdf.png", title ="Download Free PDF reader", link = "http://www.adobe.com/products/reader"
    elsif  upload_content_type == 'application/vnd.ms-powerpoint'
      return logo =  "icons/ppt.png", title ="Download free alternative to Microsoft Word/Office", link ="http://www.openoffice.org/"
    elsif  upload_content_type == 'image/jpg' || upload_content_type == 'image/jpeg' || upload_content_type ==  'image/pjpeg' || upload_content_type ==  'image/gif' || upload_content_type ==  'image/png' || upload_content_type ==  'image/x-png' || upload_content_type ==  'image/bmp'
      return logo =  "icons/image.png", title ="Download Free Image Manager", link ="http://www.gimp.org/"
    else
      return logo_image = "icons/word.png", title ="Download free alternative to Microsoft Word/Office", link ="http://www.openoffice.org/"
    end
  end
end
