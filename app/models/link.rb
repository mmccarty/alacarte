class Link < ActiveRecord::Base
  belongs_to :url_resource
  acts_as_list :scope => :url_resource

  validates :url, :format => {
  	:with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix,
  	:message => 'URL must be valid and begin with http, https, or www.'
  }
end
