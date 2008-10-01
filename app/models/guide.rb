class Guide < ActiveRecord::Base
acts_as_taggable
has_and_belongs_to_many :users, :order => 'name'
has_many :tabs,  :order => 'position', :dependent => :destroy
has_and_belongs_to_many :masters, :order => 'value'
has_and_belongs_to_many :subjects, :order => 'subject_name'
belongs_to :resource
after_create :create_home_tab

validates_presence_of  :guide_name
validates_uniqueness_of :guide_name

 def to_param
    "#{id}-#{guide_name.gsub(/[^a-z0-9]+/i, '-')}"
  end
  

def add_master_type(master_types)
  masters.clear
  if master_types
    master_types.each do |id|
      master = Master.find(id)
      masters << master
    end
  end
end

def add_related_subjects(subjs)
  subjects.clear
  if subjs
    subjs.each do |id|
      subject = Subject.find(id)
      subjects << subject
    end
  end
end

def add_contact_module(mod)
  self.resource_id = nil
  if mod
   self.resource_id = mod
  end
end

def add_tags(tags)
  self.tag_list = tags
  self.save
  
end

def create_home_tab
  tab = Tab.new(:tab_name => 'Quick Links')
  self.tabs << tab
end

def add_tab(tab)
 if reached_limit? == false
   tab.position = tabs.length+1
   tabs << tab
  end
end

def reached_limit?
  tabs.length > 5 ? true : false
end

def related_pages
  relate_pages = []
  subjects.each do |subj|
     pages = Page.find(:all,:conditions =>{:published => true, :subject => subj.subject_code} )
     pages.each do |page|
        relate_pages << page
     end
  end
end  


def related_guides
  relate_guides = []
  guides = Guide.find(:all, :conditions =>{:published => true})
  guides.each do |guide|
    types = guide.masters
    masters.each do |type|
       relate_guides << guide if types.include?(type) and id != guide.id
    end
  end  
  return  relate_guides.uniq
end


end
