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

class LibResource < ActiveRecord::Base
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
