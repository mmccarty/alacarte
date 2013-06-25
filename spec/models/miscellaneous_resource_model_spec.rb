require 'spec_helper'

describe MiscellaneousResource do
  it 'should require a title' do
    FactoryGirl.build(:miscellaneous_resource).should_not be_valid
  end
end
