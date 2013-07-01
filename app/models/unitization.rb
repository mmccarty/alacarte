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
end
