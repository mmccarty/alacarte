class Dod < ActiveRecord::Base
  has_many :database_dods, :dependent => :destroy
  has_many :database_resources, :through => :database_dods

  validates :title,
    :presence => { :message => "may not be blank!" },
    :uniqueness => {  :message => "{{value}} is already being used!"}

  validates :url, :presence => { :message => "may not be blank!" }
  validates :provider, :presence => { :message => "may not be blank!" }
  validates :descr, :presence => { :message => "may not be blank!" }

  def self.sort(sort=nil)
    unless sort==nil
      where("title LIKE ?", "#{sort}")
    else
      order("title")
    end
  end

  def coverage_label
    return startdate + " - " + enddate
  end
end
