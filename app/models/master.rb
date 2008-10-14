class Master < ActiveRecord::Base
  has_and_belongs_to_many :guides, :order => 'guide_name'
  
  def self.value_list
     masters = find(:all, :order => 'value')
     return masters.collect(&:value)
 end
 
 def pub_guides
   pguides = []
   guides.each do |guide|
     pguides << guide if guide.published?
   end
   return pguides
 end
 
end
