require 'spec_helper'

describe Guide do
  it 'has a valid factory' do
    FactoryGirl.create(:guide).should be_valid
  end

  it 'should require a name' do
    FactoryGirl.build(:guide, :guide_name => nil).should_not be_valid
  end

  it 'should generate predictable url parameters' do
    guide = FactoryGirl.create(:guide, :guide_name => 'My First Guide')
    guide.to_param.should eq("#{ guide.id }-My-First-Guide")
  end

  it 'should not be shared by default' do
    FactoryGirl.create(:guide).should_not be_shared
  end
end
