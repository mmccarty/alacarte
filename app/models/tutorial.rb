# == Schema Information
#
# Table name: tutorials
#
#  id                      :integer          not null, primary key
#  subject_id              :integer
#  name                    :string(255)      not null
#  description             :text
#  graded                  :boolean          default(FALSE)
#  published               :boolean          default(FALSE)
#  archived                :boolean          default(FALSE)
#  created_by              :integer
#  updated_at              :datetime
#  course_num              :string(255)
#  section_num             :text
#  pass                    :string(255)      default("p@ssword")
#  attachment_file_name    :string(550)
#  attachment_content_type :string(250)
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#  internal                :boolean
#

class Tutorial < ActiveRecord::Base
  acts_as_taggable
  has_many :units, :through => :unitizations
  has_many :unitizations, :order => :position, :dependent => :destroy
  has_many :users, :through => :authorships
  has_many :authorships,  :dependent => :destroy
  has_many :students, :order => :lastname, :dependent => :destroy
  belongs_to :subject

  serialize :section_num

  after_create :password_protect

  has_attached_file :attachment,
    :styles => { :medium => '505x405>', :thumb => '75x75>' },
    :url => "/uploads/:attachment/:style/:basename.:extension",
    :path => ":rails_root/public/uploads/:attachment/:style/:basename.:extension"

  validates_presence_of  :name
  validates_uniqueness_of :name,
    :scope => [:course_num, :section_num, :subject_id],
    :message => "is already in use. Change the Tutorial title to make it unique."

  validates_format_of :section_num,
    :with =>  /^\d+(,\d+)*$/,
    :message => "must be a comma seperated list of numbers or blank"
  validates_format_of :course_num,
    :with => /^\d+(\/\d+)?$/,
    :message => "must be a number or number/number."

  attr_protected :id

  def self.get_published_tutorials
    self.where("published = ? AND (internal = 't' OR internal IS NULL)", true).order 'name'
  end

  def self.published_tutorials
    self.where("published = ? AND (internal = 't' OR internal IS NULL)", true).order('name').select 'id, name, description'
  end

  def self.get_archived_tutorials
    self.where("archived = ? AND (internal = 't' OR internal IS NULL)", true).order('name').select 'id, name, description'
  end

  def self.get_internal_tutorials
    self.where(:published => true, :internal => true).order 'name'
  end

  def self.get_subjects tuts
    tuts.flat_map(&:subject).uniq
  end

  def self.authenticate u, p
    find_by_id_and_pass [ "id = '%d'", u ], ["pass = '%s'", p]
  end

  def to_param
    "#{ id }-#{ full_name.gsub /[^a-z0-9]+/i, '-' }"
  end

  def add_tags tags
    self.tag_list = tags
    self.save
  end

  def full_name
    "#{ course } #{ name }"
  end

  def course
    subject ? "#{ subject.subject_code } #{ course_num }" : ''
  end

  def sections
    section_num.split ','
  end

  def share uid, copy
    user = User.find uid
    if copy == "1"
      tutorial_copy = clone
      tutorial_copy.name = name + '-copy'
      tutorial_copy.created_by = user.id
      tutorial_copy.published = false
      tutorial_copy.save
      copy tutorial_copy, user
    else
      users << user
      units.map(&:resource).each { |resource| user.add_resource resource }
    end
  end

  def copy tut_copy, user
    tut_copy.users << user
    unitizations.each do |uz|
      unit = uz.unit
      mod_copies = unit.resourceables.flat_map { |r| r.resource.copy_mod(unit.title) }
      unit_copy = unit.clone
      tut_copy.units << unit_copy
      if unit_copy.save
        mod_copies.each do |mod|
          mod.update_attribute :created_by, user.name
          resource = Resource.create mod: mod
          user.add_resource resource
          unit_copy.add_resource resource
        end
      end
    end
  end

  def remove_from_shared user
    update_attribute(:created_by, users.at(1).id) if created_by.to_s == user.id.to_s
    users.delete user
    units.map(&:resources).each { |r| user.resources.delete r }
  end

  def shared?
    users.length > 1
  end

  def any_editors?
    users.map { |u| u.rights = 1 }.length > 1
  end

  def creator
    User.exists?(created_by) ? User.find(created_by).name : ''
  end

  def publish
    published == 1 ? true : false
  end

  def update_users
    resources =  units.map { |t| t.resources }.compact
    resources.each do |resource|
      users.map { |user| user.add_resource(resource) unless (user.id == @user || user.resources.include?(resource) == true) }
    end
  end

  def add_units uids
    uids.each { |uid| units << Unit.find(uid) }
  end

  def next_unit current_id
    uts = unitizations.select { |uz| uz.unit.id == current_id }.first
    next_uz = uts.lower_item
    next_uz.blank? ? nil : next_uz.unit
  end

  def prev_unit current_id
    uts = unitizations.select { |uz| uz.unit.id == current_id }.first
    prev_uz = uts.higher_item
    prev_uz.blank? ? nil : prev_uz.unit
  end

  def quizzes
    units.flat_map(&:resources).map { |a| a.mod if a.mod.instance_of? QuizResource }.compact.uniq
  end

  def get_students section = nil
    section ? students.select { |s| s.sect_num == section } : students
  end

  def clear_grades section = nil
    studs = section ? students.select { |s| s.sect_num == section } : students
    studs.each do |student|
      student.destroy
    end
    studs.length > 0 ? "Tutorial grades were successfully cleared." : "There were no grades to clear."
  end

  def possible_score
    scores = []
    quizzes.each do |q|
      scores << q.possible_points
    end
    scores.inject(0) { |sum,item| sum + item }
  end

  def password_protect
    words = ["p@ssword","passw0rd", "p@ssw0rd", "pa33word"]
    self.pass = words[rand(words.length)]
    self.save
  end

  def item_name
    full_name
  end
end
