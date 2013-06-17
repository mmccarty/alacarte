class Student < ActiveRecord::Base
  has_many :results, :order => 'position', :dependent => :destroy
  has_many :questions, :through => :results
  belongs_to :tutorial

  validates :email,
    :presence => true,
    :uniqueness => {
      :scope => :tutorial_id,
      :message => 'Our records indicate that you already have an account for this tutorial.  Please login.'
    },
    :format => {
      :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
      :allow_blank => true,
      :message => 'Invalid email'
    }

  validates :onid,
    :presence => true,
    :uniqueness => {
      :scope => :tutorial_id,
      :message => 'Our records indicate that you already have an account for this tutorial.  Please login.'
    }

  validates :firstname, :presence => true
  validates :lastname, :presence => true
  validates :sect_num, :presence => true
  validates :tutorial_id, :presence => true

  def to_csv
    possible = possible_score
    score = final_score
    FasterCSV.generate_line([
                             sect_num,
                             onid,
                             lastname,
                             firstname,
                             score,
                             possible]).chomp
  end

  def name
    firstname + " " + lastname
  end

  def self.authenticate(email, onid, id)
    student = self.find_by_tutorial_id_and_email(id, email)
    if !student.blank?
      if student.onid.downcase != onid.downcase
        return nil
      end
    else
      false
    end
    student
  end

  def self.unique_id
    rand(99999).to_i
  end

  def send_forgot(url)
    Notifications.deliver_forgot(self.email, self.onid, self.sect_num, url)
  end

  #returns a students total score on a quiz
  def get_total_score(quiz)
    quiz_results=[]
    quiz = QuizResource.find(quiz)
    questions = quiz.questions.collect{|q| q.id}
    questions.each do |question|
      result = results.where("question_id = ?", question).first
      quiz_results << result if result
    end
    quiz_results.inject(0){|sum,item| sum + item.score}
  end

  #returns a students total score on a tutorial
  def final_score
    scores=[]
    qz = tutorial.quizzes
    qz.each do |q|
      scores << get_total_score(q.id)
    end
    scores.inject(0){|sum,item| sum + item}
  end

  #returns the possible total score on a tutorial
  def possible_score
    tutorial.possible_score.to_i != 0 ? tutorial.possible_score : 1
  end

  #returns a 2X2 array of the quizes the student has taken and a list of the quizes left
  def quizes(t)
    tutorial_quizes = tutorial.quizzes.select{|q| q.graded?}.compact
    all_questions = tutorial_quizes.collect{|q| q.questions if q}.flatten.compact
    student_questions = questions.select{|q| q if all_questions.include?(q)}.flatten.compact
    s_quizes = student_questions.collect{|q| q.quiz_resource if q}.flatten.compact
    quizes_left =  tutorial_quizes - s_quizes
    return s_quizes.uniq, quizes_left.uniq
  end

  #returns a 3X3 array of question id ,the guess and the score of the quiz
  def get_results(quiz)
    values=[]
    quiz = QuizResource.find(quiz)
    quiz_results = results.select{|r| r if quiz.questions.include?(r.question)}
    quiz_results.each do |result|
      values << [result.question_id, result.guess, result.score]
    end
    values.uniq
  end

  def taken_on
    results.last.updated_at
  end
end
