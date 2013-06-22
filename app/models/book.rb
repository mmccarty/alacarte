# == Schema Information
#
# Table name: books
#
#  id               :integer          not null, primary key
#  url              :string(255)
#  description      :text
#  label            :string(255)
#  book_resource_id :integer
#  image_id         :string(255)
#  catalog_results  :text
#  location         :boolean          default(TRUE)
#  position         :integer
#

class Book < ActiveRecord::Base
  belongs_to :book_resource
  acts_as_list :scope => :book_resource
  serialize :catalog_results

  validates :url, :format => { :with => URI::regexp(%w(http https)) }
end
