class DatabaseResource < ActiveRecord::Base
has_many :resources, :as => :mod, :dependent => :destroy
has_many :database_dods, :dependent => :destroy, :order => :location
has_many :dods, :through => :database_dods

after_create :private_label

validates_presence_of :module_title

def private_label
  self.label = self.module_title
end
def add_dod(dod)
  db_dod = DatabaseDod.new(:dod_id => dod.id, :description => dod.descr, :location => self.database_dods.count+1)
  database_dods << db_dod
end

def shared?
  self.resources.each do |r|
    return false if r.users.length > 1
  end
end
end
