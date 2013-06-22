# == Schema Information
#
# Table name: masters
#
#  id    :integer          not null, primary key
#  value :string(255)      not null
#

class Master < ActiveRecord::Base
  has_and_belongs_to_many :guides

  validates :value,
    :presence => { :message => "Master value may not be blank!" },
    :uniqueness => { :message => "{{value}} is already being used!" }

  def pub_guides(gid = nil)
    guides.select{ |a| a.published? and a.id != gid }.sort! {|a,b|  a.guide_name <=> b.guide_name}
  end

  def self.get_guide_types
    order("value")
  end
end
