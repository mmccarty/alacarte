# == Schema Information
#
# Table name: videos
#
#  id                      :integer          not null, primary key
#  video_resource_id       :integer
#  url                     :string(255)
#  description             :text
#  alt                     :string(255)
#  position                :integer
#  transcript_file_name    :string(550)
#  transcript_content_type :string(250)
#  transcript_file_size    :integer
#  transcript_updated_at   :datetime
#

class Video < ActiveRecord::Base
  belongs_to :video_resource
  acts_as_list :scope => :video_resource
  has_attached_file :transcript,
  :styles => { :medium => '505x405>', :thumb => '75x75>' },
  :url => "/uploads/:attachment/:style/:basename.:extension",
  :path => ":rails_root/public/uploads/:attachment/:style/:basename.:extension"

  def video_id
    match = url.gsub(/.*v=([^&]*).*/, '\1') if !url.blank?
    return (match.blank? ? "" : match)
  end

  def self.get_id(tid)
    match = tid.gsub(/.*v=([^&]*).*/, '\1') if !tid.blank?
    return (match.blank? ? "" : match)
  end

  def retrieve_video
    begin
      video = Youtube::Video.find("#{video_id}")
    rescue Exception
      return ""
    else
      begin
        video = video.group.content.to_a[0].url
      rescue Exception
        return ""
      end
    end
    return video
  end
end
