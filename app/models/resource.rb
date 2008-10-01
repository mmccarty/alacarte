class Resource < ActiveRecord::Base
belongs_to :mod, :polymorphic =>true
has_and_belongs_to_many :users
has_many :page_resources, :dependent => :destroy
has_many :pages, :through => :page_resources
has_many :tab_resources, :dependent => :destroy
has_many :tabs, :through => :tab_resources
has_many :guides


 
 #protect these attributes so they can not be set with a POST request  
  attr_protected :id
 
  
def self.global_list(s = nil, r = nil)
   sortable = s || 'label'
   rev = r || 'false'
   global_mods = []
   all_resources = self.find(:all).uniq
   all_resources.each do |res|
     m = res.mod
     global_mods << m if m and m.global?
   end
   global_mods = global_mods.sort! {|a,b|  a.send(sortable) <=> b.send(sortable)}
   if  rev == 'true'
      global_mods = global_mods.reverse
  end
  return global_mods
end
 
  
 def delete_mods
   self.mod.destroy
 end

end
