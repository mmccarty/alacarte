require 'spec_helper'

describe LibfindResource do
  it 'has a valid factory' do
    expect(build :libfind_resource).to be_valid
  end

  it 'requires a title' do
    expect(build :libfind_resource, module_title: nil).to have(1).errors_on :module_title
  end

  it 'generates a default label' do
    mod = create :libfind_resource, module_title: 'this is the title'
    expect(mod.label).to eq 'this is the title'
  end

  context 'has targets' do
    before :each do
      @mod = create :libfind_resource
      @targets = 1.upto(3).map { build :lf_target }
      @targets.each { |target| @mod.lf_targets << target }
    end

    it 'can have many targets' do
      expect(@mod.lf_targets.length).to eq 3
    end

    it 'can add targets' do
      @mod.add_lf_targets 1.upto(2).map { build :lf_target }
      expect(@mod.lf_targets.length).to eq 2
    end

    it 'can generate a string of targets' do
      expect(@mod.get_targets).to eq 'target,target,target'
    end
  end
end
