require 'spec_helper'

describe Master do
  it 'has a valid factory' do
    FactoryGirl.create(:master).should be_valid
  end

  it 'should sort by value' do
    10.times { FactoryGirl.create :master }
    masters = Master.get_guide_types
    sorted = masters.sort { |x, y| x.value <=> y.value }
    masters.should eq(sorted)
  end

  #it 'should require a value' do
  #  FactoryGirl.build(:guide, :value => nil).should_not be_valid
  #end
end
