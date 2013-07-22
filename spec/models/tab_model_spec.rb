require 'spec_helper'

describe Tab do
  it 'has a valid factory' do
    expect(build :tab).to be_valid
  end

  it 'requires a name' do
    expect(build :tab, tab_name: nil).to have(1).errors_on :tab_name
  end

  it 'can belong to a guide' do
    tab = build :tab
    guide = create :guide
    guide.add_tab tab
    expect(tab.guide).to eq guide
  end

  it 'can belong to a page' do
    tab = build :tab
    page = create :page
    page.add_tab tab
    expect(tab.page).to eq page
  end

  it 'can belong to no more than one guide' do
    tab = build :tab
    guide1 = create :guide
    guide1.add_tab tab
    guide2 = create :guide
    guide2.add_tab tab
    expect(tab.guide).to eq guide2
  end

  it 'can belong to no more than one page' do
    tab = build :tab
    page1 = create :page
    page1.add_tab tab
    page2 = create :page
    page2.add_tab tab
    expect(tab.page).to eq page2
  end

  it 'cannot belong to both a guide and a page' do
    tab = build :tab
    guide = create :guide
    guide.add_tab tab
    page = create :page
    page.add_tab tab

    expect(tab.guide).to be_empty
    expect(tab.page).to eq page
  end

  describe 'layouts' do
    before :each do
      @tab  = build :tab
      guide = create :guide
      guide.add_tab @tab
    end

    it 'defaults to a two-column layout' do
      expect(@tab.num_columns).to eq 2
    end

    it 'can switch from two- to one-column layouts' do
      @tab.toggle_columns
      expect(@tab.num_columns).to eq 1
    end

    it 'can switch from one- to two-column layouts' do
      tab = build :tab, template: 1
      guide = create :guide
      guide.add_tab tab
      tab.toggle_columns
      expect(tab.num_columns).to eq 2
    end
  end

  describe 'with a one-column layout' do
    it 'lays out all modules in sequence' do
      tab = build :tab, template: 1
      guide = create :guide
      guide.add_tab tab
      mods = 1.upto(6).map { create :miscellaneous_resource }
      mods.each { |mod| tab.add_resource Resource.create(mod: mod) }
      expect(tab.sorted_modules).to eq mods
    end
  end

  describe 'with a two-column layout' do
    it 'alternately places modules into the left or right columns' do
      tab = build :tab, template: 2
      guide = create :guide
      guide.add_tab tab
      mods = 1.upto(6).map { create :miscellaneous_resource }
      mods.each { |mod| tab.add_resource Resource.create(mod: mod) }
      expect(tab.left_modules).to eq [mods[0], mods[2], mods[4]]
      expect(tab.right_modules).to eq [mods[1], mods[3], mods[5]]
    end
  end

  describe 'acts as list' do
    it 'has modules' do
      tab = build :tab, template: 1
      mod = create :miscellaneous_resource
      res = Resource.create mod: mod
      tab.add_resource res
      expect(tab.modules).to eq [mod]
    end

    it 'can re-order modules' do
      tab = build :tab, template: 1
      guide = create :guide
      guide.add_tab tab
      mods = 1.upto(3).map { create :miscellaneous_resource }
      res = mods.map { |mod| Resource.create mod: mod }
      res.each { |resource| tab.add_resource resource }
      tab.reorder_modules [res[2].id, res[0].id, res[1].id]
      tab.reload
      expect(tab.sorted_modules).to eq [mods[2], mods[0], mods[1]]
    end
  end
end
