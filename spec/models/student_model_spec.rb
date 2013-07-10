require 'spec_helper'

describe Subject do
  it 'has a valid factory' do
    expect(build :subject).to be_valid
  end

  it 'should require a code' do
    expect(build :subject, subject_code: nil).to have(1).errors_on :subject_code
  end

  it 'should require a name' do
    expect(build :subject, subject_name: nil).to have(1).errors_on :subject_name
  end

  it 'should require a unique code' do
    subject = create :subject
    expect(build :subject, subject_code: subject.subject_code).to have(1).errors_on :subject_code
  end

  #it 'should require a unique name' do
  #  subject = create :subject
  #  expect(build :subject, subject_name: subject.subject_name).to have(1).errors_on :subject_name
  #end

  it 'should generate predictable url parameters' do
    subject = create(:subject, subject_name: 'Software-Engineering')
    expect(subject.to_param).to eq "#{ subject.id }-Software-Engineering"
  end

  #it 'should sort by code' do
  #  10.times { create :subject }
  #  subjects = Subject.get_subjects
  #  sorted   = subjects.sort_by { |x| x.subject_code }
  #  expect(subjects).to eq sorted
  #end

  #it 'should sort by name' do
  #  10.times { create :subject }
  #  subjects = Subject.get_subject_values
  #  sorted   = subjects.sort_by { |x| x.subject_name }
  #  expect(subjects).to eq sorted
  #end

  it 'should return a list of guides' do
    subject = create :subject
    guides  = 1.upto(5).map { guide = create :published_guide; guide.subjects << subject; guide }
    expect(subject.get_guides).to eq(guides.sort_by { |guide| guide.guide_name })
  end
end
