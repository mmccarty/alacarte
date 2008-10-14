class RssResource < ActiveRecord::Base
has_many :resources, :as => :mod,  :dependent => :destroy
after_create :private_label

validates_presence_of :module_title

def private_label
  self.label = self.module_title
end

def shared?
  self.resources.each do |r|
    return false if r.users.length > 1
  end
end

def reader
 "http://feed2js.org//feed2js.php?src="+self.rss_feed_url+"&amp;num=5&amp;targ=y&amp;utf=y&amp;pc=y"
end

end
