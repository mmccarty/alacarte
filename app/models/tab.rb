class Tab < ActiveRecord::Base
belongs_to :guide
has_many :tab_resources, :order => :position, :dependent => :destroy
has_many :resources, :through => :tab_resources
acts_as_list :scope => :guide
  

validates_presence_of  :tab_name

#add a resource to the HABTM relationship
def add_resource(resource)
    resources << resource
end

#update a users resource list
def update_resource(resrs, user_resrs)
    resrs.each do |value|
               id = value.gsub(/[^0-9]/, '')
               type = value.gsub(/[^A-Za-z]/, '')
               resource = user_resrs.find_by_mod_id_and_mod_type(id,type)
               resources << resource
           end
end


def add_module(id, type)
  resource = Resource.find_by_mod_id_and_mod_type(id,type)
  resources << resource if resource
end

def find_resource(id, type)
   return resources.find_by_mod_id_and_mod_type(id, type)
end

#get the collection of associated resources
def modules
   resources.collect { |a| a.mod}
end 

def odd_modules
      odd = []
      tab_resources.each do |mod|
         if mod.position.odd?
            odd << mod
         end
     end
     return odd
  
end

def even_modules
  even = []
      tab_resources.each do |mod|
         if mod.position.even?
            even << mod
         end
     end
     return even
end
def left_modules
      odd = []
      tab_resources.each do |res|
         if res.position.odd?
             mod = res.resource.mod
            odd << mod
         end
     end
     return odd
  
end

def right_modules
  even = []
      tab_resources.each do |res|
         if res.position.even?
            mod = res.resource.mod
            even << mod
         end
     end
     return even
end


end
