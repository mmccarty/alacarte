require 'spec_helper'

describe QuizResource do
  it 'has a valid factory' do
    expect(build :quiz_resource).to be_valid
  end

  it 'requires a title' do
    expect(build :quiz_resource, module_title: nil).to have(1).errors_on :module_title
  end

  it 'generates a default label' do
    mod = create :quiz_resource, module_title: 'database resource title'
    expect(mod.label).to eq 'database resource title'
  end

  context 'has questions' do
    before :each do
      @mod = create :quiz_resource
      @questions = 1.upto(3).map { build :question }
      @questions.each { |q| @mod.questions << q }
    end

    it 'can have many questions' do
      expect(@mod.questions.length).to eq 3
    end

    it 'clones contain the same questions as the original' do
      copied_mod = @mod.clone
      expect(copied_mod.questions).to match_array @questions
    end

    it 'can generate a list of stand alone copied questions' do
      questions = @mod.copy_questions
      expect(questions).to match_array @questions
    end

    it 'can save questions' do
      @mod.questions.each do |q|
        q.question = 'gone'
      end
      @mod.save_questions
      expect(@mod.questions.collect{ |q| q.question }).to eq ['gone', 'gone', 'gone']
    end

    it 'can check to see if a student has taken the it' do
      expect(@mod.check_student build :student).to eq false
    end

    it 'can calculate the possible points' do
      expect(@mod.possible_points).to eq 3
    end
  end
end
