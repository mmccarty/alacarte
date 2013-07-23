require 'spec_helper'

describe Link do
  it 'has a valid factory' do
    expect(build :link).to be_valid
  end

  it 'requires a url to be valid' do
    expect(build :link, url: 'invalid url').to have(1).errors_on :url
  end

end
