require 'spec_helper'

describe Dod do
  it 'should have a valid factory' do
    expect(build :dod).to be_valid
  end

  it 'should require a title' do
    expect(build :dod, title: nil).to have(1).errors_on :title
  end

  it 'should require a url' do
    expect(build :dod, url: nil).to have(1).errors_on :url
  end

  it 'should require a provider' do
    expect(build :dod, provider: nil).to have(1).errors_on :provider
  end

  it 'should require a description' do
    expect(build :dod, descr: nil).to have(1).errors_on :descr
  end

  it 'should generate a coverage label' do
    dod = create :dod, startdate: 'then', enddate: 'now'
    expect(dod.coverage_label).to eq 'then - now'
  end
end
