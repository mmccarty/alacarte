require 'spec_helper'

describe Guide do
  it 'has a valid factory' do
    expect(build :guide).to be_valid
  end

  it 'requires a name' do
    expect(build :guide, guide_name: nil).to have(1).errors_on :guide_name
  end

  it 'generates predictable url parameters' do
    guide = create(:guide, guide_name: 'My First Guide')
    expect(guide.to_param).to eq "#{ guide.id }-my-first-guide"
  end

  it 'is by default not published (1)' do
    guide = create :guide
    expect(guide.published).to be false
  end

  it 'is by default not published (2)' do
    expect(Guide.published_guides).to be_empty
  end

  describe 'has modules' do
    it 'lists modules through its tabs' do
      guide = create :guide
      tab = build :tab
      guide.add_tab tab
      user = create :author

      mods = 1.upto(5).map { create :node }
      mods.each { |mod| user.create_and_add_node mod; tab.add_node mod.id }

      expect(guide.nodes).to eq mods
    end
  end

  describe 'has tabs' do
    it 'constructs a default tab' do
      guide = create :guide
      expect(guide.tabs.length).to eq 1
    end

    it 'allows tabs to be added' do
      guide = create :guide
      guide.add_tab(build :tab)
      expect(guide.tabs.length).to eq 2
    end

    it 'limits the total number of tabs' do
      guide = create :guide
      6.times { guide.add_tab(build :tab) }
      expect(guide).to be_reached_limit
    end
  end

  describe 'has users' do
    it 'is by default not shared' do
      expect(create :guide).to_not be_shared
    end

    it 'can be shared' do
      guide = create :guide
      user1 = create :author
      user2 = create :author

      guide.users << user1
      expect(guide).to_not be_shared

      guide.share user2.id, false
      expect(guide).to be_shared
    end

    it 'will share all required modules' do
      guide = create :guide
      tab = build :tab
      guide.add_tab tab
      user1 = create :author
      user2 = create :author

      mods = 1.upto(5).map { create :node }
      mods.each { |mod| user1.create_and_add_node mod; tab.add_node mod.id }

      guide.share user2.id, false
      user2.reload
      expect(user2.nodes.length).to eq 5
    end

    it 'will share and copy all modules' do
      guide = create :guide
      tab = build :tab
      guide.add_tab tab
      user1 = create :author
      user2 = create :author

      mods = 1.upto(5).map { create :node }
      mods.each { |mod| user1.create_and_add_node mod; tab.add_node mod.id }

      expect {
        guide.share user2.id, '1'
      }.to change(Node, :count).by(5)
    end

    it 'ensures all users share newly added modules' do
      guide = create :guide
      tab = build :tab
      guide.add_tab tab
      user1 = create :author
      user2 = create :author

      guide.share user2.id, false

      mods = 1.upto(5).map { create :node }
      mods.each { |mod| user1.create_and_add_node mod; tab.add_node mod.id }
      guide.update_users

      user2.reload
      expect(user2.nodes.length).to eq 5
    end


  end

  describe 'is taggable' do
    it 'can be tagged' do
      guide = create :guide
      guide.add_tags 'this, that, the other'
      expect(guide.tags.map(&:name).sort).to eq ['that', 'the other', 'this']
    end

    it 'can be found by tag' do
      guide = create :guide
      guide.add_tags 'this, that, the other'
      expect(Guide.tagged_with('this').first).to eq guide
    end
  end

  describe 'related guides' do
    it 'generates a list of related guides' do
      master = create :master
      guides = 1.upto(5).map { guide = create :published_guide; guide.masters << master; guide }
      guide  = guides[1]
      guides.delete guide
      expect(guide.get_related_guides.sort).to eq(guides.map(&:id).sort)
    end

    it 'does not permit duplicates in the list of related guides' do
      master1 = create :master
      master2 = create :master
      guides = 1.upto(5).map { guide = create :published_guide; guide.masters << master1 << master2; guide }
      guide  = guides[1]
      guides.delete guide
      expect(guide.get_related_guides.sort).to eq(guides.map(&:id).sort)
    end

    it 'allows setting of master subjects by id' do
      masters = 1.upto(3).map { create :master }
      guide = create :guide
      guide.add_master_type(masters.map &:id)
      expect(guide.masters).to eq masters
    end

    it 'allows explicit definition of related guides' do
      guide1 = create :published_guide
      guide2 = create :published_guide
      guide1.add_related_guides [guide2.id]
      guide1.save
      expect(guide1.related_guides).to eq [guide2]
    end

    it 'does not expect relatedness to be reciprocal' do
      guide1 = create :published_guide
      guide2 = create :published_guide
      guide1.add_related_guides [guide2.id]
      guide1.save
      expect(guide2.related_guides).to be_empty
    end

    it 'suggests related guides' do
      master = create :master
      guides = 1.upto(5).map { guide = create :published_guide; guide.masters << master; guide }
      guide  = guides[0]
      guides.delete guide
      expect(guide.suggested_relateds.map(&:id).sort).to eq(guides.map(&:id).sort)
    end

    it 'defaults to the suggested relateds on creation' do
      master = create :master
      guides = 1.upto(5).map { guide = create :published_guide; guide.masters << master; guide }
      guide = create :guide, masters: [master]
      expect(guide.related_guides).to eq(guides.sort_by &:guide_name)
    end

    it 'removes unpublished guides from the list of related' do
      master = create :master
      guides = 1.upto(5).map { guide = create :published_guide; guide.masters << master; guide }
      guide  = guides[1]
      guides.delete guide
      guide.suggested_relateds
      guides.each { |guide| guide.published = false; guide.save }
      expect(guide.related_guides).to be_empty
    end
  end
end
