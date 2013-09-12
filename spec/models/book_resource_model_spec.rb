require 'spec_helper'

describe BookResource do
  it 'has a valid factory' do
    expect(build :book_resource).to be_valid
  end

  it 'requires a module title' do
    expect(build :book_resource, module_title: nil).to have(1).errors_on :module_title
  end

  it 'generates a default label' do
    mod = create :book_resource, module_title: "I'm a module!"
    expect(mod.label).to eq "I'm a module!"
  end

  it 'will not override an explicit label' do
    mod = create :book_resource, label: 'I provided a label.'
    expect(mod.label).to eq 'I provided a label.'
  end

  it 'is taggable' do
    mod = create :book_resource, tag_list: 'you, all, everybody'
    expect(mod.tags.map &:name).to match_array %w(you all everybody)
  end

  it 'has books' do
    mod = create :book_resource
    mod.books << create(:book)
    expect(mod.books.length).to eq 1
  end
end
