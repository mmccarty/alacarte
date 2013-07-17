require 'spec_helper'

describe Unit do
  it 'has a valid factory' do
    expect(build :unit).to be_valid
  end

  it 'requires a title' do
    expect(build :unit, title: nil).to have(1).errors_on :title
  end

  it 'generates a slug' do
    unit = create :unit, title: 'abcdefghijklmnop'
    expect(unit.slug).to eq 'abcdefghijkl...'
  end

  it 'is taggable' do
    unit = create :unit
    unit.add_tags 'this, that, the other'
    expect(unit.tags.map(&:name).sort).to eq ['that', 'the other', 'this']
  end

  it 'has modules' do
    mod  = create :miscellaneous_resource
    user = create :author
    user.create_and_add_resource mod

    unit = create :unit
    unit.add_module mod.id, mod.class

    expect(unit.modules).to eq [mod]
  end

  it 'lists recent modules' do
    mod  = create :miscellaneous_resource
    user = create :author
    user.create_and_add_resource mod

    unit = create :unit
    unit.add_module mod.id, mod.class

    expect(unit.recent_modules).to eq [mod]
  end

  describe 'module sequence' do
    before :each do
      @unit = create :unit
      @mods = 1.upto(5).map { create :miscellaneous_resource }

      user = create :author
      @mods.each do |mod|
        user.create_and_add_resource mod
        @unit.add_module mod.id, mod.class
      end
    end

    it 'acts as a list' do
      expect(@unit.sorted_resources.map &:mod).to eq @mods
    end

    it 'has a first module' do
      expect(@unit.first_module).to eq @mods[0]
    end

    it 'has a last module' do
      expect(@unit.last_module).to eq @mods[4]
    end

    it 'navigates to the next module' do
      mod = @unit.first_module
      expect(@unit.next_module mod.id, mod.class).to eq @mods[1]
    end

    it 'navigates to the previous module' do
      mod = @unit.last_module
      expect(@unit.prev_module mod.id, mod.class).to eq @mods[3]
    end

    it 'will not walk off the end' do
      mod = @unit.last_module
      expect(@unit.next_module mod.id, mod.class).to be_nil
    end

    it 'will not walk off the front' do
      mod = @unit.first_module
      expect(@unit.prev_module mod.id, mod.class).to be_nil
    end
  end
end
