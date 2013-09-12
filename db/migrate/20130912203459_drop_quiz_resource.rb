class DropQuizResource < ActiveRecord::Migration
  def change
    drop_table :answers
    drop_table :questions
    drop_table :quiz_resources
    drop_table :results
    drop_table :students
  end
end
