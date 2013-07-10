require 'spec_helper'

describe MiscellaneousResource do
  it 'should have a valid factory' do
    expect(build(:miscellaneous_resource)).to be_valid
  end

  it 'should require a title' do
    expect(build(:miscellaneous_resource, module_title: nil)).to have(1).errors_on :module_title
  end

  it 'should by default not be shared' do
    expect(create(:miscellaneous_resource)).to_not be_shared
  end

  it 'should by default not be used' do
    expect(create(:miscellaneous_resource)).to_not be_used
  end

  it 'should by default belong to no pages' do
    expect(create(:miscellaneous_resource).get_pages).to be_empty
  end

  it 'should by default belong to no guides' do
    expect(create(:miscellaneous_resource).get_guides).to be_empty
  end

  it 'should by default belong to no tutorials' do
    expect(create(:miscellaneous_resource).get_tutorials).to be_empty
  end

  it 'should support adding tags' do
    mod = create :miscellaneous_resource
    mod.add_tags 'this, that'
    expect(mod.tags.map { |tag| tag.name }.sort).to eq ['that', 'this']
  end

  it 'should support finding by tag' do
    mod = create :miscellaneous_resource
    mod.add_tags 'this, that'
    expect(MiscellaneousResource.tagged_with('this').first).to eq mod
  end
end
