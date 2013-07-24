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
      expect(copied_mod.links).to eq @links
    end

    it 'can build new link attributes' do
      @mod.new_link_attributes= {'1' => {url: 'www.boo.com', label: 'foo'}}
      expect(@mod.links.last.url).to eq 'www.boo.com'
    end

    it 'can modify existing link attributes' do
      attrs = @links.map{ |l| [l.id.to_s, {label: 'gone', url: l.url }] }
      @mod.existing_link_attributes= Hash[*attrs.flatten]
      expect(@mod.links.map { |l| l.label }).to eq ['gone', 'gone', 'gone']
    end

    it 'can save all links' do
      @mod.links.each do |l|
        l.label = 'gone'
      end
      @mod.save_links
      expect(@mod.links.map { |l| l.label }).to eq ['gone', 'gone', 'gone']
    end
  end
end
