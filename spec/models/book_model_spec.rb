require 'spec_helper'

describe Book do
  it 'has a valid factory' do
    expect(build :book).to be_valid
  end

  it 'requires a url' do
    expect(Book.new).to have(1).errors_on :url
  end

  it 'requires urls to be in a valid format' do
    expect(Book.new url: 'oh hai!').to have(1).errors_on :url
  end

  it 'accepts valid urls' do
    expect(Book.new url: 'http://www.example.com').to be_valid
  end

  it 'serializes catalog results' do
    catalog_results = %w(eeny meeny miny moe)
    book = create :book, catalog_results: catalog_results
    book.reload
    expect(book.catalog_results).to eq catalog_results
  end
end
