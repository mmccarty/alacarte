# == Schema Information
#
# Table name: links
#
#  id              :integer          not null, primary key
#  url             :string(255)
#  description     :text
#  label           :string(255)
#  url_resource_id :integer
#  target          :boolean          default(FALSE)
#  position        :integer
#

class Link < ActiveRecord::Base
  belongs_to :url_resource
  acts_as_list :scope => :url_resource

  validates :url, :format => {
  	:with => /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix,
  	:message => _('URL must be valid and begin with http, https, or www.')
  }
end
