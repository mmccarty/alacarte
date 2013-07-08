require 'spec_helper'

describe Guide do
  it 'has a valid factory' do
    expect(build :guide).to be_valid
  end

  it 'should require a name' do
    expect(build :guide, guide_name: nil).to have(1).errors_on :guide_name
  end

  it 'should generate predictable url parameters' do
    guide = create(:guide, guide_name: 'My First Guide')
    expect(guide.to_param).to eq "#{ guide.id }-My-First-Guide"
  end

  it 'should by default not be shared' do
    expect(create :guide).to_not be_shared
  end

  it 'should by default not be published (1)' do
    guide = create :guide
    expect(guide.published).to be false
  end

  it 'should by default not be published (2)' do
    expect(Guide.published_guides).to be_empty
  end

  it 'should generate a list of related guides' do
    master = create :master
    guides = 1.upto(5).map { guide = create :published_guide; guide.masters << master; guide }
    guide  = guides[1]
    guides.delete guide
    expect(guide.get_related_guides.sort).to eq(guides.map { |guide| guide.id }.sort)
  end

  it 'should not permit duplicates in the list of related guides' do
    master1 = create :master
    master2 = create :master
    guides = 1.upto(5).map { guide = create :published_guide; guide.masters << master1 << master2; guide }
    guide  = guides[1]
    guides.delete guide
    expect(guide.get_related_guides.sort).to eq(guides.map { |guide| guide.id }.sort)
  end

  it 'should allow setting of master subjects by id' do
    masters = 1.upto(3).map { create :master }
    guide = create :guide
    guide.add_master_type(masters.map { |master| master.id })
    expect(guide.masters).to eq masters
  end

  it 'should allow explicit definition of related guides' do
    guide1 = create :published_guide
    guide2 = create :published_guide
    guide1.add_related_guides [guide2.id]
    guide1.save
    expect(guide1.related_guides).to eq [guide2]
  end

  it 'should not expect relatedness to be reciprocal' do
    guide1 = create :published_guide
    guide2 = create :published_guide
    guide1.add_related_guides [guide2.id]
    guide1.save
    expect(guide2.related_guides).to be_empty
  end

  it 'should suggest related guides' do
    master = create :master
    guides = 1.upto(5).map { guide = create :published_guide; guide.masters << master; guide }
    guide  = guides[0]
    guides.delete guide
    expect(guide.suggested_relateds.map { |guide| guide.id }.sort).to eq(guides.map { |guide| guide.id }.sort)
  end

  it 'should default to the suggested relateds on creation' do
    master = create :master
    guides = 1.upto(5).map { guide = create :published_guide; guide.masters << master; guide }
    guide = create :guide, masters: [master]
    expect(guide.related_guides).to eq(guides.sort_by { |guide| guide.guide_name })
  end

  it 'should remove unpublished guides from the list of related' do
    master = create :master
    guides = 1.upto(5).map { guide = create :published_guide; guide.masters << master; guide }
    guide  = guides[1]
    guides.delete guide
    guide.suggested_relateds
    guides.each { |guide| guide.published = false; guide.save }
    expect(guide.related_guides).to be_empty
  end

  it 'should support adding tags' do
    guide = create :guide
    guide.add_tags 'this, that'
    expect(guide.tags.map { |tag| tag.name }.sort).to eq ['that', 'this']
  end

  it 'should support finding by tag' do
    guide = create :guide
    guide.add_tags 'this, that'
    expect(Guide.tagged_with('this').first).to eq guide
  end
end

