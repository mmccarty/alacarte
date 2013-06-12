class Result < ActiveRecord::Base
  belongs_to :student
  belongs_to :question
  attr_protected :id

  def self.saved_answer(id, sid)
    where("question_id = ? AND student_id = ?", id, sid).first
  end

  def self.clear_answer(id, sid)
    result = where("question_id = ? AND student_id = ?", id, sid).first
    destroy(result) if result
  end

  def self.clear_all_saved_answers(sid)
    where(:student_id => sid).find_each { |result| destroy(result) }
  end

  def self.get_answer(id,sid)
    result = where("question_id = ? AND student_id = ?", id, sid).first
    result ? result.guess : nil
  end
end
