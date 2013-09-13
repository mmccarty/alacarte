require 'spec_helper'

describe Node do
  it 'has a valid factory' do
    expect(build :node).to be_valid
  end

  it 'requires a title' do
    expect(build :node, module_title: nil).to have(1).errors_on :module_title
  end

  it 'can have tags' do
    mod = create :node
    mod.add_tags 'this, that, the other'
    expect(mod.tags.map(&:name).sort).to eq ['that', 'the other', 'this']
  end

  it 'can be found via its tags' do
    mod = create :node
    mod.add_tags 'this, that, the other'
    expect(Node.tagged_with('this').first).to eq mod
  end

  it 'constructs a default label' do
    mod = create :node, module_title: 'in ur title, defaultin ur label'
    expect(mod.label).to eq 'in ur title, defaultin ur label'
  end

  it 'does not overwrite an explicit label' do
    mod = create :node, label: 'explicitly provided label'
    expect(mod.label).to eq 'explicitly provided label'
  end

  it 'is by default not shared' do
    expect(create :node).to_not be_shared
  end

  it 'is by default not used' do
    expect(create :node).to_not be_used
  end

  it 'belongs by default to no guides' do
    expect(create(:node).get_guides).to be_empty
  end

  it 'belongs by default to no pages' do
    expect(create(:node).get_pages).to be_empty
  end
end
