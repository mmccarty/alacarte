require 'spec_helper'

describe User do
  describe 'author' do
    it 'has a valid factory' do
      expect(create :author).to be_valid
    end

    it 'requires a username' do
      expect(build :author, name: nil).to_not be_valid
    end

    it 'requires an email address' do
      expect(build :author, email: nil).to_not be_valid
    end

    it 'defaults to the role of "author"' do
      expect(create(:author).role).to eq 'author'
    end

    it 'has no pages by default' do
      expect(create(:author).pages).to be_empty
    end

    it 'has no guides by default' do
      expect(create(:author).guides).to be_empty
    end

    it 'has no tutorials by default' do
      expect(create(:author).tutorials).to be_empty
    end

    it 'generates a random string' do
      string = User.random_string 54
      expect(string.length).to eq 54
    end

    it 'authenticates a user' do
      user = create :author
      expect(User.authenticate user.email, user.password).to eq user
    end

    it 'finds resources' do
      mod = create :miscellaneous_resource
      res = Resource.create mod: mod
      user = create :author
      user.add_resource res
      expect(user.find_resource mod.id, mod.class.name).to eq res
    end

    it 'understands module tags' do
      mod = create :miscellaneous_resource
      mod.add_tags 'this, that'
      user = create :author
      user.create_and_add_resource mod
      expect(user.module_tags.sort).to eq %w(that this)
    end

    it 'finds modules by tag' do
      mod = create :miscellaneous_resource
      mod.add_tags 'this, that'
      user = create :author
      user.create_and_add_resource mod
      expect(user.find_mods_tagged_with 'this').to eq [mod]
    end

    describe 'authorships' do
      it 'has tutorials' do
        tutorial = create :tutorial
        user = create :author
        user.add_tutorial tutorial
        expect(user.sort_tutorials nil).to eq [tutorial]
      end

      it 'adds the user to the list of tutorial authors' do
        tutorial = create :tutorial
        user = create :author
        user.add_tutorial tutorial
        expect(tutorial.users).to eq [user]
      end
    end

    it 'has units' do
      user = create :author
      unit = create :unit, created_by: user.id
      expect(user.units).to eq [unit]
    end
  end

  describe 'admin' do
    it 'has a role of "admin"' do
      expect(create(:admin).is_admin).to be true
    end
  end
end
