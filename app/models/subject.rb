# == Schema Information
#
# Table name: subjects
#
#  id           :integer          not null, primary key
#  subject_code :string(255)      default("")
#  subject_name :string(255)      default("")
#

class Subject < ActiveRecord::Base
  has_and_belongs_to_many :guides, order: 'guide_name'
  has_and_belongs_to_many :pages, order: 'course_num, course_name'
  has_many :tutorials, order: 'name'

  validates :subject_code, presence: true, uniqueness: true
  validates :subject_name, presence: true, uniqueness: true

  def self.get_subjects
    order :subject_code
  end

  def self.get_subject_values
    order :subject_name
  end

  def self.get_page_subjects(pages)
    pages.map {|a| a.subjects}.flatten.uniq.sort_by { |a| a.subject_code }
  end

  def to_param
    "#{id}-#{subject_name.gsub(/[^a-z0-9]+/i, '-')}"
  end

  def get_pages
    pages.select { |a| a.published? }.sort_by { |a| a.browse_title(subject_code) }
  end

  def get_tutorials
    tutorials.select { |a| a.published? }.sort_by { |a| a.full_name }
  end

  def get_guides
    guides.select { |a| a.published? }.sort_by { |a| a.guide_name }
  end
end
