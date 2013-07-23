require 'spec_helper'

describe ReserveResource do
  it 'has a valid factory' do
    expect(build :reserve_resource).to be_valid
  end

  it 'requires a title' do
    expect(build :reserve_resource, module_title: nil).to have(1).errors_on :module_title
  end

  it 'generates a default label' do
    mod = create :reserve_resource, module_title: 'this is the title'
    expect(mod.label).to eq mod.module_title
  end

  it 'can empty library reserves' do
    mod = build :reserve_resource, library_reserves: 'foo'
    mod.after_create
    expect(mod.library_reserves).to eq []
  end
end
