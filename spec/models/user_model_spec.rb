require 'spec_helper'

describe User do
  it 'has a valid factory' do
    expect(build :user).to be_valid
  end

  it 'requires a name' do
    expect(build :user, name: nil).to have(1).errors_on :name
  end

  it 'requires an email address' do
    expect(build :user, email: nil).to have(1).errors_on :email
  end

  it 'requires a properly formatted email address' do
    expect(build :user, email: 'ba neep, gra na weep ninibon').to have(1).errors_on :email
  end

  it 'requires a unique email address' do
    create :user, email: 'user@example.com'
    expect(build :user, email: 'user@example.com').to have(1).errors_on :email
  end

  it 'requires a password of sufficient length' do
    expect(build :user, password: '', password_confirmation: '').to have(1).errors_on :password
  end

  it 'requires a password confirmation' do
    expect(build :user, password_confirmation: nil).to have(1).errors_on :password_confirmation
  end

  it 'requires the password and password confirmation to match' do
    expect(build :user, password: 'asdf', password_confirmation: 'aoeu').to have(1).errors_on :password_confirmation
  end

  it 'defaults to the role of "author"' do
    expect(create(:user).role).to eq 'author'
  end

  it 'can only have a role of "author", "admin", or "pending"' do
    expect(build :user, role: 'house-elf').to have(1).errors_on :role
  end

  describe 'admin' do
    it 'has a role of "admin"' do
      admin = create :admin
      expect(admin.role).to eq 'admin'
      expect(admin.is_admin).to be_true
    end
  end

  describe 'authentication' do
    it 'authenticates login attempts' do
      user = create :user
      expect(User.authenticate user.email, user.password).to eq user
    end

    it 'creates new accounts' do
      user = User.create_new_account attributes_for(:user)
      expect(user.role).to eq 'pending'
      expect(user.is_pending).to be_true
    end

    it 'generates random strings' do
      expect(User.random_string 54).to be_an_instance_of String
    end

    it 'does not require a salt' do
      expect(build :user, salt: nil).to be_valid
    end

    it 'can generate a salt' do
      user = create :user, salt: nil
      expect(user.salt).to_not be_nil
    end

    it 'will not override an explicit salt' do
      user = create :user, salt: 'abcd'
      expect(user.salt).to eq 'abcd'
    end

    it 'can generate new passwords' do
      user = create :user
      expect(user.generate_password).to be_an_instance_of String
    end

    it 'hashes passwords' do
      expect(User.encrypt 'password', 'salt').to eq 'c88e9c67041a74e0357befdff93f87dde0904214'
    end

    it 'generates a password hash' do
      user = create :user, password: 'password', password_confirmation: 'password', salt: 'salt'
      expect(user.hashed_psswrd).to eq 'c88e9c67041a74e0357befdff93f87dde0904214'
    end

    it 'regenerates the hash when a password is assigned' do
      user = create :user, salt: 'salt'
      user.password = 'password'
      expect(user.hashed_psswrd).to eq 'c88e9c67041a74e0357befdff93f87dde0904214'
    end
  end

  describe 'author' do
    describe 'has a profile' do
      it 'has by default no profile' do
        expect(create(:author).get_profile).to be_empty
      end

      it 'can have a profile' do
        user = create :author
        mod = create :miscellaneous_resource
        res = Resource.create mod: mod
        user.add_profile res.id
        expect(user.get_profile).to eq mod
      end

      it 'can only have one profile' do
        user = create :author
        mod1 = create :miscellaneous_resource
        res1 = Resource.create mod: mod1
        user.add_profile res1.id

        mod2 = create :miscellaneous_resource
        res2 = Resource.create mod: mod2
        user.add_profile res2.id

        expect(user.get_profile).to eq mod2
      end
    end

    describe 'has contact resources' do
      it 'allows custom content as a contact resource' do
        user = create :author
        mod = create :miscellaneous_resource
        res = Resource.create mod: mod
        user.add_resource res
        expect(user.contact_resources).to include res
      end

      it 'allows an instructor profile as a contact resource' do
        user = create :author
        mod = create :inst_resource
        res = Resource.create mod: mod
        user.add_resource res
        expect(user.contact_resources).to include res
      end
    end

    describe 'has guides' do
      it 'has by default no guides' do
        expect(create(:author).guides).to be_empty
      end

      it 'can add guides' do
        user = create :author
        guide = create :guide
        user.add_guide guide
        expect(user.guides).to eq [guide]
      end

      it 'sets the owner when adding guides' do
        user = create :author
        guide = create :guide
        user.add_guide guide
        expect(guide.created_by).to eq user.name
      end

      it 'adds associations with the resources in a guide' do
        user1 = create :author
        user2 = create :author
        guide = create :guide
        tab = build :tab
        mod = create :miscellaneous_resource

        user1.create_and_add_resource mod, tab
        guide.add_tab tab

        user2.add_guide_tabs guide
        expect(user2.resources).to_not be_empty
      end
    end

    describe 'has modules' do
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
    end

    describe 'has pages' do
      it 'has by default no pages' do
        expect(create(:author).pages).to be_empty
      end

      it 'can add pages' do
        user = create :author
        page = create :page
        user.add_page page
        expect(user.pages).to eq [page]
      end

      it 'sets the owner when adding pages' do
        user = create :author
        page = create :page
        user.add_page page
        expect(page.created_by).to eq user.name
      end
    end

    describe 'has resources' do
      it 'creates resources to manage module associations' do
        user = create :author
        user.create_and_add_resource(create :miscellaneous_resource)
        expect(user.resources.length).to eq 1
      end

      it 'accesses modules by way of resources' do
        user = create :author
        user.create_and_add_resource(create :miscellaneous_resource)
        expect(user.num_modules).to eq 1
      end

      it 'sets the owner when creating resources' do
        user = create :author
        mod = create :miscellaneous_resource
        user.create_and_add_resource mod
        expect(mod.created_by).to eq user.name
      end

      it 'finds resources by id and type' do
        user = create :author
        mod = create :miscellaneous_resource
        res = Resource.create mod: mod
        user.add_resource res
        expect(user.find_resource mod.id, mod.class).to eq res
      end
    end

    describe 'has tutorials' do
      it 'has by default no tutorials' do
        expect(create(:author).tutorials).to be_empty
      end

      it 'can have tutorials' do
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

    describe 'has units' do
      it 'has by default no units' do
        expect(create(:author).units).to be_empty
      end

      it 'can have units' do
        user = create :author
        unit = create :unit, created_by: user.id
        expect(user.units).to eq [unit]
      end
    end
  end
end
