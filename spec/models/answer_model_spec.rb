require 'spec_helper'

describe Answer do
  before :each do
    @mod = build :answer,
                 question: create(:question,
                                  quiz_resource: build(:quiz_resource))
  end

  it 'has a valid factory' do
    expect(@mod).to be_valid
  end

  it 'requires a value' do
    expect(build :answer,
                 value: nil,
                 question: create(:question,
                                  quiz_resource: build(:quiz_resource))).
        to have(1).errors_on :value
  end

  it 'requires feedback for Feedback Multiple Choice questions' do
    expect(build :answer,
                 feedback: nil,
                 question: create(:question,
                                  q_type: 'FMC',
                                  quiz_resource: build(:quiz_resource))).
        to have(1).errors_on :feedback
  end

  it 'can tell if it can be skipped' do
    expect(@mod.skip_it).to be_false
  end

  it 'can tell you its feedback type' do
    expect(@mod.feedback_type).to be_false
  end
end
