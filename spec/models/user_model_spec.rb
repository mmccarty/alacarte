require 'spec_helper'

describe User do
  describe 'author' do
    it 'should have a valid factory' do
      expect(create :user).to be_valid
    end

    it 'should require a username' do
      expect(build :user, name: nil).to_not be_valid
    end

    it 'should require an email address' do
      expect(build :user, email: nil).to_not be_valid
    end

    it 'should default to the role of "author"' do
      expect(create(:user).role).to eq 'author'
    end

    it 'should by default have no pages' do
      expect(create(:user).pages).to be_empty
    end

    it 'should by default have no guides' do
      expect(create(:user).guides).to be_empty
    end

    it 'should by default have no tutorials' do
      expect(create(:user).tutorials).to be_empty
    end
  end

  describe 'admin' do
    it 'should have a role of "admin"' do
      expect(create(:admin).is_admin).to be true
    end
  end

  describe 'user' do
    it 'should be able to generate random string' do
      string = User.random_string 54
      expect(string.length).to eq 54
    end

    it 'should be able to authenticate a user' do
      user = create :user
      expect(User.authenticate user.email, user.password).to eq user
    end
  end
end
