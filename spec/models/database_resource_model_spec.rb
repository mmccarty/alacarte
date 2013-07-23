require 'spec_helper'

describe DatabaseResource do
  it 'has a valid factory' do
    expect(build :database_resource).to be_valid
  end

  it 'requires a title' do
    expect(build :database_resource, module_title: nil).to have(1).errors_on :module_title
  end

  it 'generates default label' do
    mod = create :database_resource, module_title: 'database resource title'
    expect(mod.label).to eq 'database resource title'
  end

  context 'has dods' do
    before :each do
      @mod = create :database_resource
      @dods = 1.upto(3).map { build :dod }
      @dods.each { |dod| @mod.dods << dod }
    end

    it 'can have many dods' do
      expect(@mod.dods.length).to eq 3
    end

    it 'clones contain same dods as original' do
      copied_mod = @mod.clone
      expect(copied_mod.dods).to eq @dods
    end

    it 'can add dod' do
      @mod.add_dod create :dod
      expect(@mod.dods.length).to eq 4
    end
  end
end
