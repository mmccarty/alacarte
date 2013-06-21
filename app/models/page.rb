class Page < ActiveRecord::Base
  acts_as_taggable
  has_and_belongs_to_many :users
  has_many :tabs, :as => 'tabable',  :order => 'position', :dependent => :destroy
  has_and_belongs_to_many :subjects, :order => 'subject_code'
  belongs_to :resource

  serialize :relateds
  after_create :create_relateds

  validates_presence_of :course_name,:course_num, :subjects
  validates_associated :subjects

  validates_uniqueness_of :course_name,
    :scope => [:course_num, :term, :year,  :sect_num],
    :message => "is already in use. Change the Page Title to make a unique page."

  validates_format_of :sect_num,
    :with => /^\d{0,}$/,
    :message => "must be a number or blank"
  validates_format_of :course_num,
    :with => /^(\d{1,}\/?\d{1,})*$/,
    :message => "must be a number or numbers ( e.g, 121 or 121/123)."

  attr_protected :id

  def validate
    errors.add "You must specify at least one subject." if subjects.blank?
  end

  def to_param
    "#{id}-#{route_title.gsub(/[^a-z0-9]+/i, '-')}"
  end

  def header_title
    subject = ""
    self.subject_codes.each do |subj|
      subject = subject + if subject != "" then "/" else "" end + subj.to_s
    end
    subject + " " + course_num + ":" + " " + course_name
  end

  def subject_codes
    subjects.collect { |s| s.subject_code}
  end

  def subject_names
    subjects.collect { |s| s.subject_name}
  end

  def browse_title(subj,campushash={})
    @campustrans = ((campushash.has_key?(campus)?campushash[campus]:campus))
    subj + " " + course_num + ":" + " " + course_name +  "    " + unless term == "A" then term else "" end +
      unless year == "A" then year else "" end + " " +  unless sect_num.blank? then " " + "#" + sect_num else  "" end +  unless campus == "A" then " (" + @campustrans + ")" else  "" end
  end

  def search_title
    subject = ""
    self.subject_codes.each do |subj|
      subject = subject + if subject != "" then "/" else "" end + subj.to_s
    end
    subject + " " + course_num + ":" + " " + course_name +  "    " + unless term == "A" then term else "" end +
      unless year == "A" then year else "" end + " " +  unless sect_num.blank? then " " + "#" + sect_num else  "" end
  end

  def route_title
    subject = ""
    self.subject_codes.each do |subj|
      subject = subject + if subject != "" then "/" else "" end + subj.to_s
    end
    subject+course_num
  end

  def create_relateds
    self.relateds = get_related_guides
    self.save
  end

  def delete_relateds(id)
    relateds.delete(id.to_i)
    self.save
  end

  def add_related_guides(ids)
    ids.each do |id|
      relateds << id.to_i unless relateds.include?(id.to_i)
    end
  end

  def related_guides
    guides=[]
    if relateds == nil
      create_relateds
    end
    relateds.each do |id|
      if Guide.exists?(id.to_i)
        guide = Guide.find(id.to_i)
        if guide.published?
          guides << guide
        else
          relateds.delete(id.to_i)
        end
      else
        relateds.delete(id.to_i)
      end
    end
    guides.sort { |x,y| x.guide_name.downcase <=> y.guide_name.downcase }
  end

  def suggested_relateds
    ids = get_related_guides
    add_related_guides(ids)
    self.save
    related_guides
  end

  def get_related_guides
    gds = subjects.collect{|a| a.get_guides}.flatten
    gds = gds.collect{|a| a.id}.compact
    (gds.blank? ? [] : gds)
  end

  def add_contact_module(mid)
    resource_id = nil
    if mid
      resource_id = mid.to_i
    end
  end

  def self.get_branch_published_pages(branch)
    self.where(:published => true, :campus => branch).order("subject, course_num").select('id, subject, course_num, course_name, term, year, sect_num, page_description')
  end

  def self.get_published_pages
    self.where(:published => true).includes("subjects").order("subjects.subject_code, course_num").select('id, course_num, course_name, term, year, sect_num, page_description')
  end

  def self.get_archived_pages(subj=nil)
    pages = self.where(:archived => true).includes("subjects").order("subjects.subject_code, course_num").select('id, course_num, course_name, term, year, sect_num, page_description')
    if !subj.blank?
      pages = pages.select{|p| p.subjects.include?(subj)}
    end
    pages
  end

  def add_user(user)
    users << user
  end

  def add_tab(tab)
    tabs << tab
  end

  def add_subjects(subjs)
    subjects.clear
    if subjs
      subjs.each do |id|
        subject = Subject.find_by_id(id)
        subjects << subject
      end
    end
  end

  def shared?
    users.length > 1
  end

  def share(uid, copy)
    user = User.find(uid)
    if copy  == "1"
      share_copy(user)
    else
      users << user
      resources =  tabs.collect{|t| t.resources}.compact
      resources.each do |resource|
        user.add_resource(resource)
      end
    end
  end

  def share_copy(user)
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
      mod_copies = tab.tab_resources.collect{|r| r.resource.copy_mod(route_title)}.flatten
      tab_copy = tab.clone
      if tab_copy.save
        mod_copies.each do |mod|
          resource = Resource.create(:mod => mod)
          user.add_resource(resource)
          tab_copy.add_resource(resource)
        end
        page_copy.add_tab(tab_copy)
      end
    end
  end

  def copy_tabs(tbs)
    tbs.each do |tab|
      tab_copy = tab.clone
      if tab_copy.save
        tab.tab_resources.each do |res|
          tab_copy.add_resource(res.resource)
        end
        add_tab(tab_copy)
      end
    end
  end

  def copy_resources(uid, tbs)
    user = User.find(uid)
    tbs.each do |tab|
      mod_copies = tab.tab_resources.collect{|r| r.resource.copy_mod(tab.page.route_title)}.flatten
      tab_copy = tab.clone
      if tab_copy.save
        mod_copies.each do |mod|
          mod.update_attribute(:created_by, user.name)
          resource = Resource.create(:mod => mod)
          user.add_resource(resource)
          tab_copy.add_resource(resource)
        end
        add_tab(tab_copy)
      end
    end
  end

  def create_home_tab
    tab = Tab.new(:tab_name => 'Start')
    self.tabs << tab
  end

  def reached_limit?
    tabs.length > 6 ? true : false
  end

  def modules
    tbs = []
    tbs << tabs.collect{|t| t.modules}
    tbs.flatten
  end

  def recent_modules
    tabs.collect{|t| t.recent_modules}.flatten
  end

  def add_tags(tags)
    self.tag_list = tags
    self.save
  end

  def update_users
    resources =  tabs.collect{|t| t.resources}.compact
    resources.each do |resource|
      users.collect{|user| user.add_resource(resource) unless(user.id == @user || user.resources.include?(resource) == true)}
    end
  end

  def index_subjects_name
    subjects.map{|subject| subject.subject_name}.join(", ")
  end

  def index_subjects_code
    subjects.map{|subject| subject.subject_code}.join(", ")
  end

  def index_tab_name
    tabs.map{|tab| tab.tab_name}.join(", ")
  end
end
