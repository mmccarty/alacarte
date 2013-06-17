class BookResource < ActiveRecord::Base
  include HasResources

  acts_as_taggable
  has_many :resources, :as => :mod,  :dependent => :destroy
  has_many :books, :order => :position,  :dependent => :destroy
  before_create :private_label
  after_update :save_books

  validates :module_title, :presence => true
  validates :label, :presence => { :on => :update }

  def private_label
    self.label = self.module_title
  end

  def new_book_attributes=(book_attributes)
    book_attributes.each do |attributes|
      books.build(attributes)
    end
  end

  def existing_book_attributes=(book_attributes)
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

  def add_tags(tags)
    self.tag_list = tags
    self.save
  end
end
