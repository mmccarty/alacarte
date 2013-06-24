# == Schema Information
#
# Table name: feeds
#
#  id              :integer          not null, primary key
#  label           :string(255)      default(""), not null
#  url             :string(255)      not null
#  rss_resource_id :integer          not null
#

class Feed < ActiveRecord::Base
  belongs_to :rss_resource
end
