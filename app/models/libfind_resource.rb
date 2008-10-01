class LibfindResource < ActiveRecord::Base
has_many :resources, :as => :mod, :dependent => :destroy
has_many :lf_targets, :dependent => :delete_all
after_create :private_label

validates_presence_of :module_title


def private_label
  self.label = self.module_title
end
  
def get_targets
  lf_targets.collect{|a| a.value}.join(",")
end
def shared?
  self.resources.each do |r|
    return false if r.users.length > 1
  end
end

def search
 "http://search.library.oregonstate.edu/record/retrieve"
end
end
