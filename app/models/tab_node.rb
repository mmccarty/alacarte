# == Schema Information
#
# Table name: tab_nodes
#
#  id       :integer          not null, primary key
#  tab_id   :integer
#  node_id  :integer
#  position :integer
#

class TabNode < ActiveRecord::Base
  belongs_to :tab
  belongs_to :node
  acts_as_list scope: :tab
end
