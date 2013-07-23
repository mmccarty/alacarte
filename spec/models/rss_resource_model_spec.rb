require 'spec_helper'

describe RssResource do
  it 'has a valid factory' do
    expect(build :rss_resource).to be_valid
  end

  it 'requires a title' do
    expect(build :rss_resource, module_title: nil).to have(1).errors_on :module_title
  end

  it 'generates a default label' do
    mod = create :rss_resource, module_title: 'this is the title'
    expect(mod.label).to eq mod.module_title
  end

  context 'has feeds and' do
    before :each do
      @mod = create :rss_resource
      @feeds = 1.upto(3).map { build :feed }
      @feeds.each { |feed| @mod.feeds << feed }
    end
    it 'can have many feeds' do
      expect(@mod.feeds.length).to eq 3
    end

    it 'will copy feeds when cloning' do
      copied_mod = @mod.clone
      expect(copied_mod.feeds.reverse).to eq @feeds
    end

    it 'can build new feed attributes' do
      @mod.new_feed_attributes= [:url => 'www.boo.com']
      expect(@mod.feeds.last.url).to eq 'www.boo.com'
    end

    it 'can modify existing feed attributes' do
      attrs = @feeds.map{ |feed| [feed.id.to_s, {label: 'gone', url: feed.url }] }
      @mod.existing_feed_attributes= Hash[*attrs.flatten]
      expect(@mod.feeds.map { |f| f.label }).to eq ['gone', 'gone', 'gone']
    end

    it 'can generate a list of feed urls' do
      expect(@mod.feedurls.length).to eq 3
    end

    it 'can generate a list of feed labels' do
      expect(@mod.feedlabels.length).to eq 3
    end

    it 'can provide a js reader' do
      expect(@mod.reader).to be_a_kind_of String
    end

    it 'can save all feeds' do
      @mod.feeds.each do |f|
        f.label = 'gone'
      end
      @mod.save_feeds
      expect(@mod.feeds.map { |f| f.label }).to eq ['gone', 'gone', 'gone']
    end
  end
end
