require 'spec_helper'

describe Master do
  it 'has a valid factory' do
    expect(build :master).to be_valid
  end

  it 'should require a value' do
    expect(build :master, value: nil).to have(1).errors_on :value
  end

  it 'should sort by value' do
    10.times { create :master }
    masters = Master.get_guide_types
    sorted  = masters.sort_by &:value
    expect(masters).to eq sorted
  end

  it 'should support any number of guides' do
    master = create :master
    guides = 1.upto(5).map { guide = create :guide; guide.masters << master; guide}
    expect(master.guides.sort_by &:id).to eq guides
  end

  it 'should sort published guides by name' do
    master = create :master
    guides = 1.upto(5).map { guide = create :published_guide; guide.masters << master; guide }
    expect(master.pub_guides).to eq(guides.sort_by &:guide_name)
  end

  it 'should elide the current guide from the list of published guides' do
    master = create :master
    guides = 1.upto(5).map { guide = create :published_guide; guide.masters << master; guide }
    guide  = guides[1]
    guides.delete guide
    expect(master.pub_guides guide.id).to eq(guides.sort_by &:guide_name)
  end
end
