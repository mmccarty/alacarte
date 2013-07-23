require 'spec_helper'

describe Feed do
  it 'has a valid factory' do
    expect(build :feed).to be_valid
  end

  it 'requires a label' do
    expect(build :feed, label: nil).to have(1).errors_on :label
  end

  it 'requires a url' do
    expect(build :feed, url: nil).to have(1).errors_on :url
  end

  it 'requires a valid url' do
    expect(build :feed, url: 'invalid url').to have(1).errors_on :url
  end

  it 'belongs to a rss resource' do
    mod = build :feed, rss_resource: build(:rss_resource)
    expect(mod.rss_resource).to be_valid
  end
end
