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
#  node_id          :integer
#  created_by       :string(255)
#  relateds         :text
#

class Page < ActiveRecord::Base
  include ItsJustAPage
  after_create :create_home_tab, :create_relateds

  acts_as_taggable
  has_and_belongs_to_many :users
  has_many :tabs, -> { order 'position' }, :as => 'tabable', :dependent => :destroy
  has_and_belongs_to_many :subjects, -> { order 'subject_code' }
  belongs_to :node

  serialize :relateds

  validates :course_name, presence: true
  validates :course_num, presence: true

  validates_uniqueness_of :course_name,
    :scope => [:course_num, :term, :year,  :sect_num],
    :message => _('is already in use. Change the Page Title to make a unique page.')

  validates_format_of :sect_num,
    :with => /\A\d*\z/,
    :message => _('must be a number or blank')
  validates_format_of :course_num,
    :with => /\A\d+(\/\d+)?\z/,
    :message => _('must be a number or numbers (e.g, 121 or 121/123).')

  searchable do
    text :course_name, :page_description
  end

  def validate
    errors.add _('You must specify at least one subject.') if subjects.blank?
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

  def add_contact_node mid
    self.node_id = if mid then mid.to_i else nil end
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

  def add_subjects subject_ids
    subjects.clear
    if subject_ids
      subject_ids.each do |id|
        subjects << Subject.find_by_id(id)
      end
    end
  end

  def create_home_tab
    if tabs.blank?
      add_tab Tab.new(tab_name: _('Start'))
    end
  end

  def replicate user, options
    new_page = dup
    num_pages = Page.where('course_name like :prefix', prefix: "#{ course_name}%").count
    new_page.course_name = "#{ course_name }-#{ num_pages + 1}"
    if options == 'copy'
      new_page.copy_nodes user.id, tabs
    else
      new_page.copy_tabs tabs
    end

    new_page.add_tags tag_list
    new_page.add_subjects subjects.map(&:id)
    new_page
  end

  def item_name
    header_title
  end
end
