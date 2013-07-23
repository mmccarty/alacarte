require 'spec_helper'

describe Student do
  it 'has a valid factory' do
    expect(build :student).to be_valid
  end

  it 'requires a valid email' do
    expect(build :student, email: 'invalid email').to have(1).errors_on :email
  end

  it 'requires a unique email for a tutorial' do
    mod = create :student
    expect(build :student).to have(1).errors_on :email
  end

  it 'requires a unique account for a tutorial' do
    mod = create :student, onid: 'foo'
    expect(build :student, onid: 'foo').to have(1).errors_on :onid
  end

  it 'requires a firstname' do
    expect(build :student, firstname: nil).to have(1).errors_on :firstname
  end

  it 'requires a lastname' do
    expect(build :student, lastname: nil).to have(1).errors_on :lastname
  end

  it 'requires a section number' do
    expect(build :student, sect_num: nil).to have(1).errors_on :sect_num
  end

  it 'requires a tutorial' do
    expect(build :student, tutorial_id: nil).to have(1).errors_on :tutorial_id
  end

  it 'can have answered questions' do
    mod = create :student
    question = create :question,
                      quiz_resource: build(:quiz_resource)
    question.save_answer 'this is my answer', mod.id
    question = Question.find(question.id)
    expect(mod.questions.length).to eq 1
  end

  it 'can generate a csv representation' do
    mod = build :student,
                tutorial: build(:tutorial)
    expect(mod.to_csv).to be_a_kind_of String
  end

  it 'can generate a name' do
    mod = build :student
    expect(mod.name).to be_a_kind_of String
  end

  it 'can authenticate' do
    mod = create :student, onid: 'ted'
    expect(Student.authenticate mod.email, mod.onid, mod.tutorial_id).to eq mod
  end

  it 'fails to authenticate by returning nil' do
    mod = create :student, onid: 'ted'
    expect(Student.authenticate mod.email, 'wrong', mod.tutorial_id).to be_nil
  end

  it 'can generate a unique id' do
    expect(Student.unique_id).to be_a_kind_of Integer
  end

  context 'takes quizes and' do
    before :each do
      @tutorial = create :tutorial
      @mod = create :student,
                    tutorial: @tutorial
      @quiz = create :quiz_resource
      @unit = create :unit
      @resource = Resource.new(:mod_id => @quiz.id, :mod_type => 'QuizResource')
      @unit.resources << @resource
      @tutorial.add_units [@unit.id]
      @question = create :question,
                        points: 10,
                        quiz_resource: @quiz
      @question.answers << create(:answer,
                                 correct: true,
                                 value: 'a',
                                 question: @question)
      @question.answers << create(:answer, value: 'b', question: @question)
      @question.grade_answer 'a', @mod
    end

    it 'can calculate a total score on a given quiz' do
      expect(@mod.get_total_score @quiz).to eq 10
    end

    it 'can calculate a total score on a tutorial' do
      expect(@mod.final_score).to eq 10
    end

    it 'can calculate a total possible score on a tutorial' do
      expect(@mod.possible_score).to eq 10
    end

    it 'can report a list of quizes it has taken and those left to take' do
      expect(@mod.quizes.length).to eq 2
    end

    it 'can report the results for a given quiz' do
      expect(@mod.get_results(@quiz).length).to eq 1
    end

    it 'can give the last date it has taken a quiz' do
      expect(@mod.taken_on).to be_a_kind_of @mod.results.last.updated_at.class
    end
  end

end