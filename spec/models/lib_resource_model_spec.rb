require 'spec_helper'

describe LibResource do
  it 'has a valid factory' do
    expect(build :lib_resource).to be_valid
  end

  it 'requires a title' do
    expect(build :lib_resource, module_title: nil).to have(1).errors_on :module_title
  end

  it 'generates a default label' do
    mod = create :lib_resource, module_title: 'this is the title'
    expect(mod.label).to eq 'this is the title'
  end

  it 'does not require an email' do
    expect(build :lib_resource, email: nil).to be_valid
  end

  it 'requires an email address to be valid' do
    expect(build :lib_resource, email: 'invalid email').to have(1).errors_on :email
  end

  it 'can accept a valid email address' do
    expect(build :lib_resource, email: 'foo@bar.com').to be_valid
  end
end
