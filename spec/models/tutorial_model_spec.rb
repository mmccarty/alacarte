require 'spec_helper'

describe Tutorial do
  it 'has a valid factory' do
    expect(build :tutorial).to be_valid
  end

  it 'requires a name' do
    expect(build :tutorial, name: nil).to have(1).errors_on :name
  end

  it 'requires course numbers to be numbers' do
    expect(build :tutorial, course_num: 'abc').to have(1).errors_on :course_num
  end

  it 'requires section numbers to be numbers' do
    expect(build :tutorial, section_num: 'abc').to have(1).errors_on :section_num
  end

  it 'generates a simple default password' do
    expect(create(:tutorial).pass).to_not be_nil
  end

  it 'constructs a course name' do
    subject  = create :subject, subject_code: 'ENGR', subject_name: 'Engineering'
    tutorial = create :tutorial, name: 'Getting Started', course_num: '101'
    tutorial.subject = subject
    expect(tutorial.course).to eq 'ENGR 101'
  end

  it 'constructs a full name' do
    subject  = create :subject, subject_code: 'ENGR', subject_name: 'Engineering'
    tutorial = create :tutorial, name: 'Getting Started', course_num: '101'
    tutorial.subject = subject
    expect(tutorial.full_name).to eq 'ENGR 101 Getting Started'
  end

  it 'generates predictable URL parameters' do
    subject  = create :subject, subject_code: 'ENGR', subject_name: 'Engineering'
    tutorial = create :tutorial, name: 'Getting Started', course_num: '101'
    tutorial.subject = subject
    expect(tutorial.to_param).to eq "#{ tutorial.id }-ENGR-101-Getting-Started"
  end

  it 'has sections' do
    tutorial = create :tutorial, section_num: '101,201,301'
    expect(tutorial.sections).to eq %w(101 201 301)
  end

  it 'is by default not shared' do
    expect(create :tutorial).to_not be_shared
  end

  it 'has a creator' do
    user = create :user
    tutorial = create :tutorial, created_by: user.id
    expect(tutorial.creator).to eq user.name
  end

  describe 'unit sequence' do
    before :each do
      @units = 1.upto(5).map { create :unit }
      @tutorial = create :tutorial
      @tutorial.add_units @units.map(&:id)
    end

    it 'has a next unit' do
      unit = @units[0]
      expect(@tutorial.next_unit unit.id).to eq @units[1]
    end

    it 'has a previous unit' do
      unit = @units[4]
      expect(@tutorial.prev_unit unit.id).to eq @units[3]
    end

    it 'will not walk off the end' do
      unit = @units[4]
      expect(@tutorial.next_unit unit.id).to be_nil
    end

    it 'will not walk off the front' do
      unit = @units[0]
      expect(@tutorial.prev_unit unit.id).to be_nil
    end

    it 'recognizes quizes as a special kind of module' do
      expect(@tutorial.quizzes).to be_empty
    end
  end
end
