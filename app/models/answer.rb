# == Schema Information
#
# Table name: answers
#
#  id          :integer          not null, primary key
#  question_id :integer
#  value       :text
#  correct     :boolean          default(FALSE)
#  position    :integer
#  feedback    :text
#

class Answer < ActiveRecord::Base
  belongs_to :question
  acts_as_list :scope => :question

  validates :value, :presence => { :message => "Answer can not be blank", :unless => :skip_it }
  validates :feedback, :presence => { :message => "Feedback can not be blank", :if => :feedback_type }

  def skip_it
    question.q_type.in? %w(TF FW)
  end

  def feedback_type
    question.q_type == 'FMC'
  end
end
