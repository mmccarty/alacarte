class CommentResource < ActiveRecord::Base
  has_many :resources, :as => :mod, :dependent => :destroy
  has_many :comments, :dependent => :delete_all
  
 after_create :private_label

validates_presence_of :module_title

def private_label
  self.label = self.module_title
end



  def ordered_comments
    self.comments.find(:all, :limit => self.num_displayed, :order => "created_at DESC")
  end

def shared?
  self.resources.each do |r|
    return false if r.users.length > 1
  end
end
end

