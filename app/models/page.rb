# == Schema Information
#
# Table name: pages
#
#  id               :integer          not null, primary key
#  published        :boolean          default(FALSE)
#  sect_num         :string(255)
#  course_name      :string(255)      not null
#  term             :string(255)      default("")
#  year             :string(255)      default("")
#  campus           :string(255)      default("")
#  course_num       :string(255)
#  page_description :text
#  updated_at       :datetime
#  created_on       :date
#  archived         :boolean          default(FALSE)
#  resource_id      :integer
#  created_by       :string(255)
#  relateds         :text
#

class Page < ActiveRecord::Base
  include ItsJustAPage
  after_create :create_home_tab, :create_relateds

  acts_as_taggable
  has_and_belongs_to_many :users
  has_many :tabs, :as => 'tabable',  :order => 'position', :dependent => :destroy
  has_and_belongs_to_many :subjects, :order => 'subject_code'
  belongs_to :resource

  serialize :relateds

  validates_presence_of :course_name,:course_num, :subjects
  validates_associated :subjects

  validates_uniqueness_of :course_name,
    :scope => [:course_num, :term, :year,  :sect_num],
    :message => "is already in use. Change the Page Title to make a unique page."

  validates_format_of :sect_num,
    :with => /^\d*$/,
    :message => "must be a number or blank"
  validates_format_of :course_num,
    :with => /^\d+(\/\d+)?$/,
    :message => "must be a number or numbers (e.g, 121 or 121/123)."

  attr_protected :id

  def validate
    errors.add "You must specify at least one subject." if subjects.blank?
  end

  def to_param
    "#{ id }-#{ route_title.gsub /[^a-z0-9]+/i, '-' }"
  end

  def header_title
    "#{ subject_codes.join '/' } #{ course_num }: #{ course_name }"
  end

  def subject_codes
    subjects.map &:subject_code
  end

  def subject_names
    subjects.map &:subject_name
  end

  def browse_title subj, campushash = {}
    @campustrans = ((campushash.has_key?(campus)?campushash[campus]:campus))
    subj + " " + course_num + ":" + " " + course_name +  "    " + unless term == "A" then term else "" end +
      unless year == "A" then year else "" end + " " +  unless sect_num.blank? then " " + "#" + sect_num else  "" end +  unless campus == "A" then " (" + @campustrans + ")" else  "" end
  end

  def search_title
    "#{ header_title }    #{ term == 'A' ? '' : term }#{ year == 'A' ? '' : year } #{ sect_num.blank? ? '' : ' #' + sect_num }"
  end

  def route_title
    subject_codes.join('/') + course_num
  end

  def get_related_guides
    subjects.flat_map(&:get_guides).map &:id
  end

  def add_contact_module mid
    resource_id = nil
    if mid
      resource_id = mid.to_i
    end
  end

  def self.get_branch_published_pages branch
    self.where(:published => true, :campus => branch).order("subject, course_num").select('id, subject, course_num, course_name, term, year, sect_num, page_description')
  end

  def self.get_published_pages
    self.where(:published => true).includes("subjects").order("subjects.subject_code, course_num").select('id, course_num, course_name, term, year, sect_num, page_description')
  end

  def self.get_archived_pages subj = nil
    pages = self.where(:archived => true).includes("subjects").order("subjects.subject_code, course_num").select('id, course_num, course_name, term, year, sect_num, page_description')
    unless subj.blank?
      pages = pages.select{|p| p.subjects.include?(subj)}
    end
    pages
  end

  def add_subjects subjs
    subjects.clear
    if subjs
      subjs.each do |id|
        subjects << Subject.find_by_id(id)
      end
    end
  end

  def share_copy user
    page_copy = clone
    page_copy.course_name = course_name + '-copy'
    subjects.each do |subject|
      page_copy.subjects << subject
    end
    page_copy.created_by = user.id
    page_copy.published = false
    page_copy.save

    page_copy.users << user

    tabs.each do |tab|
      mod_copies = tab.tab_resources.flat_map { |r| r.resource.copy_mod(route_title) }
      tab_copy = tab.clone
      if tab_copy.save
        mod_copies.each do |mod|
          resource = Resource.create mod: mod
          user.add_resource resource
          tab_copy.add_resource resource
        end
        page_copy.add_tab tab_copy
      end
    end
  end

  def copy_resources uid, tbs
    user = User.find uid
    tbs.each do |tab|
      mod_copies = tab.tab_resources.flat_map { |r| r.resource.copy_mod(tab.page.route_title) }
      tab_copy = tab.clone
      if tab_copy.save
        mod_copies.each do |mod|
          mod.update_attribute :created_by, user.name
          resource = Resource.create mod: mod
          user.add_resource resource
          tab_copy.add_resource resource
        end
        add_tab tab_copy
      end
    end
  end

  def create_home_tab
    add_tab Tab.new(tab_name: 'Start')
  end
end
