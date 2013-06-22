# == Schema Information
#
# Table name: resourceables
#
#  id          :integer          not null, primary key
#  resource_id :integer          not null
#  unit_id     :integer          not null
#  position    :integer
#

class Resourceable < ActiveRecord::Base
  belongs_to :resource
  belongs_to :unit
  acts_as_list :scope => :unit
end
