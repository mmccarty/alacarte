# == Schema Information
#
# Table name: comments
#
#  id                  :integer          not null, primary key
#  comment_resource_id :integer          not null
#  author_name         :string(255)      default("Anonymous"), not null
#  author_email        :string(255)
#  body                :text             not null
#  created_at          :datetime         not null
#

class Comment < ActiveRecord::Base
  belongs_to :comment_resource

  validates :body, presence: { message: _('is required') }
  validates :author_email, format: { with: /\A(([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,}))?\z/i }
  validate :is_clean?

  scope :most_recent_first, lambda { order 'created_at DESC' }

  BAD_WORDS = IO.readlines("#{ Rails.root }/lib/words.txt").each(&:chop!).freeze

  def is_clean?
    BAD_WORDS.each do |line|
      (body || '').split.each do |word|
        word.gsub! /[^\w]/, ''
        if word.downcase == line.strip.downcase
          errors.add :body, _('Comment included an inappropriate word')
          return
        end
      end
    end
  end
end
