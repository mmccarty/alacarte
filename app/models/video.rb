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