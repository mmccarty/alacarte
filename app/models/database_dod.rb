# == Schema Information
#
# Table name: database_dods
#
#  id                   :integer          not null, primary key
#  database_resource_id :integer          not null
#  dod_id               :integer          not null
#  description          :text
#  location             :integer
#

class DatabaseDod < ActiveRecord::Base
 belongs_to :dod
 belongs_to :database_resource
end
