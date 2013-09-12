# == Schema Information
#
# Table name: book_resources
#
#  id            :integer          not null, primary key
#  module_title  :string(255)      default(""), not null
#  label         :string(255)
#  updated_at    :datetime
#  content_type  :string(255)      default("Books")
#  global        :boolean          default(FALSE)
#  created_by    :string(255)
#  created_by_id :integer
#  information   :text
#  slug          :string(255)
#  published     :boolean          default(FALSE)
#

class BookResource < ActiveRecord::Base
  include PolymorphicModule

  acts_as_taggable
  has_many :books, dependent: :destroy
  has_many :resources, as: :mod, dependent: :destroy

  before_create :private_label
  after_update :save_books

  validates :module_title, presence: true
  validates :label, presence: { on: :update }

  def copy
    mod = PolymorphicModule::copy
    mod.books << books.map(&:clone)
    mod
  end

  def new_book_attributes= book_attributes
    book_attributes.each do |attributes|
      books.build attributes
    end
  end

  def existing_book_attributes= book_attributes
    books.reject(&:new_record?).each do |book|
      attributes = book_attributes[book.id.to_s]
      if attributes
        book.attributes = attributes
      else
        books.delete(book)
      end
    end
  end

  def save_books
    books.each do |book|
      book.save false
    end
  end

  def rss_content
    self.information.blank? ? '' : self.information
  end
end
