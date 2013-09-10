# == Schema Information
#
# Table name: questions
#
#  id               :integer          not null, primary key
#  quiz_resource_id :integer          not null
#  question         :text             not null
#  position         :integer
#  points           :integer          default(0)
#  q_type           :string(255)      default("MC")
#  updated_at       :datetime
#

class Question < ActiveRecord::Base
  belongs_to :quiz_resource
  has_many :answers, :order => :position
  has_many :results,  :dependent => :destroy
  has_many :students, :through => :results, :order => :sect_num

  after_update :save_answers
  acts_as_list :scope => :quiz_resource

  validates :question, :presence => true

  def quiz_type
    case q_type
    when 'MC'
      _ 'Multiple Choice'
    when 'TF'
      _ 'True/False'
    when 'FW'
      _ 'Free Write'
    when 'FMC'
      _ 'Feedback Multiple Choice'
    else
      ''
    end
  end

  def correct_answer
    case q_type
    when 'MC'
      (correct = answers.select{|a| a.correct == true}.first) and (return (correct.blank? ? "" : correct.value))
    when 'TF'
      answers.first.correct == true ? 'true' : 'false'
    when 'FW'
      answers.blank? ? "" : answers.first.value
    when 'FMC'
      (correct = answers.select{|a| a.correct == true}.first) and (return (correct.blank? ? "" : correct.value))
    else
      ""
    end
  end

  def grade_answer(answer, student = nil)
    case q_type
    when 'MC'
      grade_MC answer, student
    when 'TF'
      grade_TF answer, student
    when 'FW'
      grade_FW answer, student
    when 'FMC'
      grade_FMC answer, student
    else
      ""
    end
  end

  def save_answer(answer, sid)
    result = Result.saved_answer(id, sid)
    if result == nil
      result =  Result.new(:guess => answer, :question_id => id, :position => position, :student_id => sid)
    else
      result.update_attribute(:guess, answer)
    end
    result.save
  end

  def grade_MC(answer, student)
    correct = correct_answer.eql?(answer)
    score = correct == true ? points : 0
    unless  student == nil  || students.include?(student) == true
      student =  Student.find(student)
      result = Result.new(:guess => answer, :score => score, :question_id => id, :position => position)
      student.results << result
    end
    return id, answer, score
  end

  def grade_FMC(answer, student)
    correct = correct_answer.eql?(answer)
    score = correct == true ? points : 0
    unless  student == nil  || students.include?(student) == true
      student =  Student.find(student)
      result = Result.new(:guess => answer, :score => score, :question_id => id, :position => position)
      student.results << result
    end
    return id, answer, score
  end

  def grade_TF(answer, student)
    answer_string = (answer == "1" ? 'true' : 'false')
    correct = correct_answer.eql?(answer_string)
    score = correct == true ? points : 0
    unless  student == nil  || students.include?(student) == true
      student = Student.find(student)
      result = Result.new(:guess => answer_string, :score => score, :question_id => id, :position => position)
      student.results << result
    end
    return id, answer_string, score
  end

  def grade_FW(answer, student)
    unless  student == nil  || students.include?(student) == true
      student = Student.find(student)
      result = Result.new(:guess => answer, :score => 0 , :question_id => id, :position => position)
      student.results << result
    end
    return id, answer, points
  end

  def save_answers
    answers.each do |answer|
      answer.save()
    end
  end

  def taken(student)
    students.include?(student)
  end
end
