require 'spec_helper'

describe MiscellaneousResource do
  it 'has a valid factory' do
    expect(build :miscellaneous_resource).to be_valid
  end

  it 'requires a title' do
    expect(build :miscellaneous_resource, module_title: nil).to have(1).errors_on :module_title
  end

  it 'generates a default label' do
    mod = create :miscellaneous_resource, module_title: 'in ur title, defaultin ur label'
    expect(mod.label).to eq 'in ur title, defaultin ur label'
  end

  it 'does not overwrite an explicit label' do
    mod = create :miscellaneous_resource, label: 'explicitly provided label'
    expect(mod.label).to eq 'explicitly provided label'
  end

  it 'is by default not be shared' do
    expect(create :miscellaneous_resource).to_not be_shared
  end

  it 'is by default not be used' do
    expect(create :miscellaneous_resource).to_not be_used
  end

  it 'belongs by default to no pages' do
    expect(create(:miscellaneous_resource).get_pages).to be_empty
  end

  it 'belongs by default to no guides' do
    expect(create(:miscellaneous_resource).get_guides).to be_empty
  end

  it 'belongs by default to no tutorials' do
    expect(create(:miscellaneous_resource).get_tutorials).to be_empty
  end

  it 'supports adding tags' do
    mod = create :miscellaneous_resource
    mod.add_tags 'this, that'
    expect(mod.tags.map(&:name).sort).to eq ['that', 'this']
  end

  it 'supports finding by tag' do
    mod = create :miscellaneous_resource
    mod.add_tags 'this, that'
    expect(MiscellaneousResource.tagged_with('this').first).to eq mod
  end
end
