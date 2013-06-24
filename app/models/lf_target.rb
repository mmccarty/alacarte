# == Schema Information
#
# Table name: lf_targets
#
#  id                  :integer          not null, primary key
#  libfind_resource_id :integer
#  value               :string(255)
#

class LfTarget < ActiveRecord::Base
  belongs_to :libfind_resource
end
