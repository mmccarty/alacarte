class InstResource < ActiveRecord::Base
has_many :resources, :as => :mod, :dependent => :destroy
after_create :private_label

validates_presence_of :module_title
validates_format_of :email, :allow_nil => true, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :if => Proc.new {|c| not c.email.blank?}
def private_label
  self.label = self.module_title
end



def shared?
  self.resources.each do |r|
    return false if r.users.length > 1
  end
end

end
