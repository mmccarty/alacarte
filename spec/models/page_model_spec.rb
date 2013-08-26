require 'spec_helper'

describe Page do
  it 'has a valid factory' do
    expect(build :page).to be_valid
  end

  it 'expect course numbers to be numbers' do
    expect(build :page, course_num: '101').to be_valid
  end

  it 'requires course numbers to be numbers' do
    expect(build :page, course_num: 'abc').to have(1).errors_on :course_num
  end

  it 'requires section numbers to be numbers' do
    expect(build :page, sect_num: 'abc').to have(1).errors_on :sect_num
  end

  describe 'has modules' do
    it 'lists modules through its tabs' do
      page = create :page
      tab = build :tab
      page.add_tab tab
      user = create :author

      mods = 1.upto(5).map { create :miscellaneous_resource }
      mods.each { |mod| user.create_and_add_resource mod; tab.add_module mod.id, mod.class }

      expect(page.modules).to eq mods
    end
  end

  describe 'has subjects' do
    it 'has subject codes' do
      page = create :page
      expect(page.subject_codes).to eq [page.subjects.first.subject_code]
    end

    it 'has subject names' do
      page = create :page
      expect(page.subject_names).to eq [page.subjects.first.subject_name]
    end
  end

  describe 'has tabs' do
    it 'constructs a default tab' do
      page = create :page
      expect(page.tabs.length).to eq 1
    end

    it 'allows tabs to be added' do
      page = create :page
      page.add_tab(build :tab)
      expect(page.tabs.length).to eq 2
    end

    it 'limits the total number of tabs' do
      page = create :page
      6.times { page.add_tab(build :tab) }
      expect(page).to be_reached_limit
    end
  end

  describe 'has titles' do
    before :each do
      @page = create :page, course_num: '101', course_name: 'Kicking Ass and Taking Names'
      @page.subjects.clear

      @subject = Subject.create subject_code: 'ENGR', subject_name: 'Engineering'
      @page.subjects << @subject
    end

    it 'generates predictable URL parameters' do
      expect(@page.to_param).to eq "#{ @page.id }-ENGR101"
    end

    it 'constructs a header title' do
      expect(@page.header_title).to eq 'ENGR 101: Kicking Ass and Taking Names'
    end

    it 'constructs a route title' do
      subject2 = Subject.create subject_code: 'COMP', subject_name: 'Computer Science'
      @page.subjects << subject2
      expect(@page.route_title).to eq 'ENGR/COMP101'
    end
  end

  describe 'has users' do
    it 'is by default not shared' do
      expect(create :page).to_not be_shared
    end

    it 'can be shared' do
      page = create :page
      user1 = create :author
      user2 = create :author

      page.users << user1
      expect(page).to_not be_shared

      page.share user2.id, false
      expect(page).to be_shared
    end

    it 'will share all required modules' do
      page = create :page
      tab = build :tab
      page.add_tab tab
      user1 = create :author
      user2 = create :author

      mods = 1.upto(5).map { create :miscellaneous_resource }
      mods.each { |mod| user1.create_and_add_resource mod; tab.add_module mod.id, mod.class }

      page.share user2.id, false
      user2.reload
      expect(user2.resources.length).to eq 5
    end

    it 'will share and copy all modules' do
      page = create :page
      tab = build :tab
      page.add_tab tab
      user1 = create :author
      user2 = create :author

      mods = 1.upto(5).map { create :miscellaneous_resource }
      mods.each { |mod| user1.create_and_add_resource mod; tab.add_module mod.id, mod.class }

      expect {
        page.share user2.id, '1'
      }.to change(MiscellaneousResource, :count).by(5)
    end

    it 'ensures all users share newly added modules' do
      page = create :page
      tab = build :tab
      page.add_tab tab
      user1 = create :author
      user2 = create :author

      page.share user2.id, false

      mods = 1.upto(5).map { create :miscellaneous_resource }
      mods.each { |mod| user1.create_and_add_resource mod; tab.add_module mod.id, mod.class }
      page.update_users

      user2.reload
      expect(user2.resources.length).to eq 5
    end
  end
end
