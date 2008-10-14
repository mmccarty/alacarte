class PageResource < ActiveRecord::Base
 belongs_to :page
 belongs_to :resource
 acts_as_list :scope => :page
  
end
