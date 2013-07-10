require 'spec_helper'

describe Tutorial do
  it 'should have a valid factory' do
    expect(build :tutorial).to be_valid
  end

  it 'should require a name' do
    expect(build :tutorial, name: nil).to have(1).errors_on :name
  end

  it 'should require course numbers to be numbers' do
    expect(build :tutorial, course_num: 'abc').to have(1).errors_on :course_num
  end

  it 'should require section numbers to be numbers' do
    expect(build :tutorial, section_num: 'abc').to have(1).errors_on :section_num
  end

  it 'should generate a simple default password' do
    expect(create(:tutorial).pass).to_not be_nil
  end

  it 'should be be named uniquely within a course'

  it 'should generate a course name' do
    subject = create :subject, subject_code: 'ENGR', subject_name: 'Engineering'
    tutorial = create :tutorial, name: 'Getting Started', course_num: '101'
    tutorial.subject = subject
    expect(tutorial.course).to eq 'ENGR 101'
  end

  it 'should generate a full name' do
    subject = create :subject, subject_code: 'ENGR', subject_name: 'Engineering'
    tutorial = create :tutorial, name: 'Getting Started', course_num: '101'
    tutorial.subject = subject
    expect(tutorial.full_name).to eq 'ENGR 101 Getting Started'
  end

  it 'should have sections' do
    tutorial = create :tutorial, section_num: '101,201,301'
    expect(tutorial.sections).to eq %w(101 201 301)
  end

  it 'should by default not be shared' do
    expect(create :tutorial).to_not be_shared
  end

  it 'should have a creator' do
    user = create :user
    tutorial = create :tutorial, created_by: user.id
    expect(tutorial.creator).to eq user.name
  end
end
