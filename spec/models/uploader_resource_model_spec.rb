require 'spec_helper'

describe UploaderResource do
  it 'has a valid factory' do
    expect(build :uploader_resource).to be_valid
  end
  it 'requires a title'
  it 'generates a default label'
  context 'has uploadables' do
    it 'can have many uploadables'
    it 'will copy uploadables when cloned'
    it 'can build new uploadable attributes'
    it 'can modify existing uploadable attributes'
    it 'can save all uploadables'
  end
end
