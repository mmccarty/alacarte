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
   rev = r || 'true'
   global_mods = self.find(:all).collect{|a| a.mod unless a.mod.global? == false }.compact
   unless global_mods.empty?
     unless sortable == "updated_at"
        global_mods = global_mods.sort! {|a,b|  a.send(sortable).downcase <=> b.send(sortable).downcase}
     else
       global_mods = global_mods.sort! {|a,b|  a.send(sortable) <=> b.send(sortable)}
     end
     if  rev == 'false'
        global_mods = global_mods.reverse
     end
   end  
   return global_mods.uniq
end
 
  
 def delete_mods
   self.mod.destroy
 end

end
