class Dod < ActiveRecord::Base
has_many :database_dods, :dependent => :destroy
has_many :database_resources, :through => :database_dods
   
def self.sort(sort=nil)
  unless sort==nil
    find(:all, :conditions => ['title LIKE ?', "#{sort}%"])
  else
    find(:all, :order => 'title')
  end  
end

def coverage_label
   label =""
    unless startdate.blank?
      label += startdate
      unless enddate.blank?
        label += " - " + enddate
      end
    else 
        label +=  enddate
    end
    return label
  end
end
