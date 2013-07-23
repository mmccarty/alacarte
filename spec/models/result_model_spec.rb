require 'spec_helper'

describe Result do
  it 'has a valid factory' do
    expect(build :result).to be_valid
  end

  it 'belongs to a student' do
    mod = build :result, student: build(:student)
    expect(mod.student).to be_valid
  end

  it 'belongs to a question' do
    mod = build :result, question: build(:question)
    expect(mod.question).to be_valid
  end

  context 'has answers and' do
    before :each do
      @student = create :student
      @question = create :question,
                         quiz_resource: build(:quiz_resource)
      @mod = create :result,
                    student: @student,
                    question: @question
    end

    it 'can retrieve saved answers' do
      expect(Result.saved_answer @question.id, @student.id).to eq @mod
    end

    it 'can clear saved a answer' do
      Result.clear_answer @question.id, @student.id
      expect(Result.saved_answer @question.id, @student.id).to eq nil
    end

    it 'can clear all saved answers' do
      Result.clear_all_saved_answers @student.id
      expect(Result.saved_answer @question.id, @student.id).to eq nil
    end

    it 'can get an answer' do
      expect(Result.get_answer @question.id, @student.id).to eq @mod.guess
    end
  end
end
