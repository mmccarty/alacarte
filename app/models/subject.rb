# == Schema Information
#
# Table name: subjects
#
#  id           :integer          not null, primary key
#  subject_code :string(255)      default("")
#  subject_name :string(255)      default("")
#

class Subject < ActiveRecord::Base
  has_and_belongs_to_many :guides, :order => 'guide_name'
  has_and_belongs_to_many :pages, :order => 'course_num, course_name'
  has_many :tutorials, :order => 'name'

  validates :subject_code,
    :presence => { :message => 'may not be blank!' },
    :uniqueness => { :message => "{{value}} is already being used!" }
  validates :subject_name,
    :presence => { :message => 'may not be blank!' },
    :uniqueness => { :message => "{{value}} is already being used!" }

  def self.get_subjects
    order :subject_code
  end

  def self.get_subject_values
    order :subject_name
  end

  def self.get_page_subjects(pages)
    pages.collect {|a| a.subjects}.flatten.uniq.sort! {|a,b|  a.subject_code <=> b.subject_code}
  end

  def to_param
    "#{id}-#{subject_name.gsub(/[^a-z0-9]+/i, '-')}"
  end

  def get_pages
    pages.select{ |a| a.published? }.sort! {|a,b|  a.browse_title(subject_code) <=> b.browse_title(subject_code)}
  end

  def get_tutorials
    tutorials.select{ |a| a.published? }.sort! {|a,b|  a.full_name <=> b.full_name}
  end

  def get_guides
    guides.select{ |a| a.published? }.sort! {|a,b|  a.guide_name <=> b.guide_name}
  end
end
