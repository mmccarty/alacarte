class QuizResource < ActiveRecord::Base
  include HasResources

  acts_as_taggable
  has_many :resources, :as => :mod,  :dependent => :destroy
  has_many :questions, :order => :position, :dependent => :destroy

  before_create :private_label
  validates :module_title, :presence => true
  validates :label, :presence => { :on => :update }

  after_update :save_questions

  def copy_questions
    question_copies = []
    questions.each do |question|
      answer_copies = question.answers.collect{|a| a.clone if a}.flatten
      question_copy = question.clone
      if question_copy.save
        answer_copies.each do |answer|
          question_copy.answers << answer
        end
        question_copies << question_copy
      end
    end
    return question_copies
  end

  def private_label
    self.label = self.module_title
  end

  def save_questions
    questions.each do |question|
      question.save(false)
    end
  end

  def rss_content
    self.description.blank? ? "" : self.description
  end

  def add_tags(tags)
    self.tag_list = tags
    self.save
  end

  def check_student(student)
    num = questions.select { |q| q if q.taken(student) == true }
    num and num.length > 0
  end

  def possible_points
    questions.inject(0){|sum,item| sum + item.points}
  end
end
