require 'spec_helper'

describe User do
  describe 'author' do
    it 'has a valid factory' do
      FactoryGirl.create(:user).should be_valid
    end

    it 'should default to the role of "author"' do
      FactoryGirl.create(:user).role.should eq('author')
    end
  end

  describe 'admin' do
    it 'should have a role of "admin"' do
      FactoryGirl.create(:admin).role.should eq('admin')
    end
  end
end
