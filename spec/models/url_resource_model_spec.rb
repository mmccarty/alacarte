require 'spec_helper'

describe UrlResource do
  it 'has a valid factory' do
    expect(build :url_resource).to be_valid
  end

  it 'requires a title' do
    expect(build :url_resource, module_title: nil).to have(1).errors_on :module_title
  end

  it 'generates a default label' do
    mod = create :url_resource, module_title: 'this is the title'
    expect(mod.label).to eq mod.module_title
  end

  context 'has links and' do
    before :each do
      @mod = create :url_resource
      @links = 1.upto(3).map { build :link }
      @links.each { |l| @mod.links << l }
    end

    it 'can have many links' do
      expect(@mod.links.length ).to eq 3
    end

    it 'will copy links when cloned' do
      copied_mod = @mod.clone
      expect(copied_mod.links).to match_array @links
    end
  end
end
