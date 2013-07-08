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
    presence:   { message: "Master value may not be blank!"   },
    uniqueness: { message: "({value}} is already being used!" }

  # Returns the list of master subjects.
  def self.get_guide_types
    order :value
  end

  # Return the list of published guides for a master, optionally excluding the one specified guide.
  def pub_guides(gid = nil)
    guides.select { |a| a.published? and a.id != gid }.sort_by { |guide| guide.guide_name }
  end
end
