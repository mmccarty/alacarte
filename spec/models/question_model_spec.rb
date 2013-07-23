require 'spec_helper'

describe Question do
  it 'has a valid factory' do
    expect(build :question).to be_valid
  end

  it 'requires a question' do
    expect(build :question, question: nil).to have(1).errors_on :question
  end

  it 'can have many students' do
    mod = build :question
    students = 1.upto(5).map { build :student }
    students.each { |s| mod.students << s }
    expect(mod.students.length).to eq 5
  end

  it 'gives a quiz type' do
    mod = build :question
    expect(mod.quiz_type).to eq 'Multiple Choice'
  end

  context 'has answers' do
    before :each do
      @mod = build :question
      @answers = 1.upto(3).map { build :answer }
      @answers.each { |a| @mod.answers << a }
    end

    it 'can have many answers' do
      expect(@mod.answers.length).to eq 3
    end

    it 'can check for a correct answer' do
      expect(@mod.correct_answer).to be_false
    end

    it 'can grade an answer' do
      id, answer, score = @mod.grade_answer build :answer
      expect(score).to eq 0
    end

    it 'can grade a multiple choice question' do
      id, answer, score = @mod.grade_MC build(:answer), create(:student)
      expect(score).to eq 0
    end
    it 'can grade a feedback multiple choice question' do
      id, answer, score = @mod.grade_FMC build(:answer), create(:student)
      expect(score).to eq 0
    end
    it 'can grade a true/false question' do
      id, answer, score = @mod.grade_TF build(:answer), create(:student)
      expect(score).to eq 0
    end
    it 'can grade a free write question' do
      id, answer, score = @mod.grade_FW build(:answer), create(:student)
      expect(score).to eq 1
    end

    it 'can save an answer' do
      student = build :student
      @mod.save_answer 'this is my answer', student.id
      result = Result.find_by_question_id @mod.id
      expect(result).to be_valid
    end

    it 'can save answers' do
      @answers.each do |a|
        a.value = 'moded'
        a.save
      end
      expect((@mod.answers.map { |a| a.value }).join(',')).to eq 'moded,moded,moded'
    end

    it 'can tell if a student has answered' do
      expect(@mod.taken create :student).to be_false
    end
  end
end
