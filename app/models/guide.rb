# == Schema Information
#
# Table name: guides
#
#  id          :integer          not null, primary key
#  guide_name  :string(255)      not null
#  resource_id :integer
#  updated_at  :datetime
#  created_by  :string(255)      default("")
#  published   :boolean          default(FALSE)
#  description :text
#  relateds    :text
#

class Guide < ActiveRecord::Base
  include ItsJustAPage
  after_create :create_home_tab, :create_relateds

  acts_as_taggable
  has_and_belongs_to_many :users
  has_many :tabs, as: 'tabable', order: 'position', dependent: :destroy
  has_and_belongs_to_many :masters
  has_and_belongs_to_many :subjects, order: 'subject_name'
  belongs_to :resource

  validates :guide_name, presence: true, uniqueness: true

  serialize :relateds

  def self.published_guides
    self.where(published: true).order(:guide_name).select 'id, guide_name, description'
  end

  def to_param
    "#{ id }-#{ guide_name.gsub /[^a-z0-9]+/i, '-' }"
  end

  # Suggest a list of related guides sharing at least one master subject.
  def get_related_guides
    masters.flat_map { |m| m.published_guides id }.map(&:id).uniq
  end

  # Define master subjects by ID.
  def add_master_type master_types
    masters.clear
    (master_types || []).each { |id| masters << Master.find(id) }
  end

  def add_related_subjects subjs
    subjects.clear
    subjs.each { |id| subjects << Subject.find(id) } if subjs
  end

  def create_home_tab
    if tabs.blank?
      add_tab Tab.new(tab_name: 'Quick Links')
    end
  end

  def related_pages
    subjects.flat_map(&:get_pages).uniq
  end

  def share_copy user
    guide_copy = clone
    guide_copy.guide_name = guide_name + '-copy'
    subjects.each do |subject|
      guide_copy.subjects << subject
    end
    masters.each do |master|
      guide_copy.masters << master
    end
    guide_copy.created_by = user.id
    guide_copy.published = false
    guide_copy.save

    guide_copy.users << user

    tabs.each do |tab|
      mod_copies = tab.tab_resources.flat_map { |r| r.resource.copy_mod(guide_name) }
      tab_copy = tab.clone
      if tab_copy.save
        mod_copies.each do |mod|
          resource = Resource.create mod: mod
          user.add_resource resource
          tab_copy.add_resource resource
        end
        guide_copy.add_tab tab_copy
      end
    end
  end

  def copy_resources uid, tbs
    # Need an id to add tabs
    save
    remove_all_tabs
    reload
    user = User.find uid
    tbs.each do |tab|
      mod_copies = tab.tab_resources.flat_map { |r| r.resource.copy_mod(tab.guide.guide_name) }
      tab_copy = tab.dup
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

  def toggle_published
    if self.resource || self.published?
      self.toggle!(:published)
      true
    else
      false
    end
  end
end
