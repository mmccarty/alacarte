class Book < ActiveRecord::Base
  belongs_to :book_resource
  acts_as_list :scope => :book_resource
  serialize :catalog_results

  validates :url, :format => { :with => URI::regexp(%w(http https)) }
end
