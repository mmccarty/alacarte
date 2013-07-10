# == Schema Information
#
# Table name: tab_resources
#
#  id          :integer          not null, primary key
#  tab_id      :integer
#  resource_id :integer
#  position    :integer
#

class TabResource < ActiveRecord::Base
  belongs_to :tab
  belongs_to :resource
  acts_as_list scope: :tab
end
