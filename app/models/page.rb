##########################################################################
#
#ICAP Tool - Publishing System for and by librarians.
#Copyright (C) 2007 Oregon State University
#
#This file is part of the ICAP project.
#
#The ICAP project is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#Questions or comments on this program may be addressed to:
#ICAP - Library Technology
#121 The Valley Library
#Corvallis OR 97331-4501
#
#http://ica.library.oregonstate.edu/about/index.html
#
########################################################################

class Page < ActiveRecord::Base
acts_as_taggable
has_and_belongs_to_many :users, :order => 'name'
has_many :page_resources, :order => :position, :dependent => :destroy
has_many :resources, :through => :page_resources
belongs_to :resource



 
   
   TERM_STYLES = [
     ["All",         "A"],
     ["Fall",        "F"],
     ["Winter",      "W"], 
     ["Spring",      "S"],
     ["Summer",     "SU"], 
                              
   ]
   
   YEAR_STYLES = [
     ["All",       "A"],  
     ["2008",      "08"], 
     ["2009",      "09"],
     ["2010",      "10"],
     ["2011",      "11"],
     ["2012",      "12"],
     ["2013",      "13"],
                           
   ]
   

  validates_presence_of :course_name,:course_num, :subject, :template
  validates_inclusion_of :term, :in => TERM_STYLES.map {|disp, value| value}
  validates_inclusion_of :year, :in => YEAR_STYLES.map {|disp, value| value}
 
  validates_uniqueness_of :course_name,
                           :scope => [:subject, :course_num, :term, :year,  :sect_num],
                           :message => "is already in use. Change the Page Title to make a unique page."
  
  validates_format_of :sect_num,
                      :with => /^\d{0,}$/,
                      :message => "must be a number or blank"
  validates_format_of :course_num,
                      :with => /^\d{0,}$/,
                      :message => "must be a number"
                   

                      
  #protect these attributes so they can not be set with a POST request  
  attr_protected :id
  
 def to_param
    "#{id}-#{route_title.gsub(/[^a-z0-9]+/i, '-')}"
  end
 
#make a nice header title 
 def header_title
    subject + " " + course_num + ":" + " " + course_name 
 end

#make a nice seach title
def search_title
    subject + " " + course_num + ":" + " " + course_name +  "    " + unless term == "A" then term else "" end +
  unless year == "A" then year else "" end + " " +  unless sect_num.blank? then " " + "#" + sect_num else  "" end 
 end

#make a nice route title
def route_title
  subject+course_num
end



#get the published pages by filter
def self.get_published_pages(subj=nil, term=nil, year=nil)
    pages = self.find(:all,:conditions => {:published => true}, :order => 'subject, course_num')
    if subj
      subj_filter=[]
      pages.each do |page|
        subj_filter << page if page.subject == subj
      end
      pages = subj_filter
    end
    if term
      term_filter=[]
      pages.each do |page|
        term_filter << page if page.term == term
      end
      pages = term_filter
    end
     if year
      year_filter=[]
      pages.each do |page|
        year_filter << page if page.year == year
      end
      pages = year_filter
    end
    return pages
end

def self.get_archived_pages(subj=nil)
    pages = self.find(:all,:conditions => {:archived => true}, :order => 'subject, course_num')
    if subj
      subj_filter=[]
      pages.each do |page|
        subj_filter << page if page.subject == subj
      end
      pages = subj_filter
    end
    return pages
end

#add a user to the HABTM relationship
def add_user(user)
   users << user
end

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

def add_contact_module(mod)
  self.resource_id = nil
  if mod
   self.resource_id = mod
  end
end


def find_resource(id, type)
   return resources.find_by_mod_id_and_mod_type(id, type)
end

#get the collection of associated resources
def modules
   resources.collect { |a| a.mod}
end 
  
def left_modules
      odd = []
      page_resources.each do |res|
         if res.position.odd?
             mod = res.resource.mod
            odd << mod
         end
     end
     return odd
  
end

def right_modules
  even = []
      page_resources.each do |res|
         if res.position.even?
            mod = res.resource.mod
            even << mod
         end
     end
     return even
end

def add_tags(tags)
  self.tag_list = tags
  self.save
  
end

def related_guides
  relate_guides = []
  target_subject = Subject.find_by_subject_code(subject)
  guides = target_subject.guides
    guides.each do |guide|
       relate_guides << guide if guide.published?
    end
  return  relate_guides.uniq
end


end
