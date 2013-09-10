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
    presence:   { message: _('Master value may not be blank!')   },
    uniqueness: { message: _('({value}} is already being used!') }

  # Returns the list of master subjects.
  def self.get_guide_types
    order :value
  end

  # Return the list of published guides for a master, optionally excluding the one specified guide.
  def published_guides(gid = 0)
    guides.where('published AND id != ?', gid).order :guide_name
  end
end
