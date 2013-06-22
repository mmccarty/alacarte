# == Schema Information
#
# Table name: unitizations
#
#  id          :integer          not null, primary key
#  unit_id     :integer          not null
#  tutorial_id :integer          not null
#  position    :integer
#

class Unitization < ActiveRecord::Base
  belongs_to :unit
  belongs_to :tutorial
  acts_as_list :scope => :tutorial
  after_create :update_ferret

  #ferret was not adding new units to the index so added this after save code in to fix it
  def update_ferret
    search = Local.first.enable_search?
    if search
      tutorial.ferret_update
    end
  end
end
