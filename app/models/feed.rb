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
  validates :label, :presence => true
  validates :url,
            :format => {
                :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix,
                :message => _('URL must be valid and begin with http, https, or www.') }

  belongs_to :rss_resource
end
