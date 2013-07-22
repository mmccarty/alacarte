require 'spec_helper'

describe InstResource do
  it 'has a valid factory' do
    expect(build :inst_resource).to be_valid
  end

  it 'requires title' do
    expect(build :inst_resource, module_title: nil).to have(1).errors_on :module_title
  end

  it 'generates default label' do
    mod = create :inst_resource, module_title: 'this is the title'
    expect(mod.label).to eq 'this is the title'
  end

  it 'does not require an email' do
    expect(build :inst_resource, email: nil).to be_valid
  end

  it 'requires email address to be valid' do
    expect(build :inst_resource, email: 'invalid email').to have(1).errors_on :email
  end

  it 'can accept a valid email address' do
    expect(build :inst_resource, email: 'foo@bar.com').to be_valid
  end

  it 'does not require a website' do
    expect(build :inst_resource, website: nil).to be_valid
  end

  it 'can accept a valid website' do
    expect(build :inst_resource, website: 'http://foo.bar.com').to be_valid
  end

  it 'requires website address to be valid' do
    expect(build :inst_resource, website: 'invalid website').to have(1).errors_on :website
  end

end
