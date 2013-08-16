# == Schema Information
#
# Table name: users
#
#  id            :integer          not null, primary key
#  name          :string(255)      default(""), not null
#  hashed_psswrd :string(255)      default(""), not null
#  email         :string(255)      default(""), not null
#  salt          :string(255)      default(""), not null
#  role          :string(255)      default("author"), not null
#  resource_id   :integer
#

require 'digest/sha1'
require 'xmlrpc/client'

class User < ActiveRecord::Base
  has_and_belongs_to_many :guides
  has_and_belongs_to_many :pages
  has_and_belongs_to_many :resources
  has_many :authorships,  :dependent => :destroy
  has_many :tutorials, :through => :authorships, :order => 'name'
  has_many :my_tutorials, :through => :authorships, :source => :tutorial, :conditions => 'authorships.rights = 1', :order => 'name'

  attr_protected :id, :salt
  attr_accessor :password_confirmation

  validates :name, length: { in: 2..54 }
  validates :email, format: { with: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }, uniqueness: true
  validates :password, length: { in: 2..54 }, confirmation: true
  validates :password_confirmation, presence: true
  validates :role, inclusion: { in: %w(admin author pending) }
  validates :salt, presence: true

  def self.authenticate email, password
    user = self.find_by_email email
    if user
      expected_password = encrypt password, user.salt
      if user.hashed_psswrd != expected_password
        user = nil
      end
    end
    user
  end

  def self.create_new_account params
    user = User.new params
    user.role = 'pending'
    user.save
    user
  end

  def self.send_pending_user_mail user, url
    local = Local.first
    begin
      Notifications.deliver_add_pending_user(user.email, local.admin_email_from)
      Notifications.deliver_notify_admin_about_pending_user(local.admin_email_to, local.admin_email_from,url)
      msg = "An account was created for you.  It is now waiting for administrator approval."
    rescue Exception => e
      logger.error("Exception in register user: #{e}}" )
      msg = "Could not send email"
    end
    return msg
  end

  def validate
    errors.add("Missing password" ) if hashed_psswrd.blank?
  end

  # Associates a user with a list of modules, by way of resource objects.
  def self.create_and_add_resource id, mod_list, item = nil
    user = find id
    mod_list.each { |mod| user.create_and_add_resource mod, item }
  end

  # Creates a "resource" to associate the current user with the given module.
  def create_and_add_resource mod, item = nil
    mod.update_attribute :created_by, name
    resource = Resource.create mod: mod
    add_resource resource
    item.add_resource resource unless item.nil?
  end

  def add_page page
    page.created_by = name
    page.resource_id = resource_id
    page.save
    pages << page
  end

  def add_guide guide
    guide.created_by = name
    guide.resource_id = resource_id
    guide.save
    guides << guide
  end

  def add_guide_tabs guide
    guides << guide
    tr = guide.tabs.map(&:tab_resources).flatten
    resources << tr.map(&:resource).flatten
  end

  def delete_guide_tabs guide
    guides.delete guide
    tr =  guide.tabs.map { |t| t.tab_resources }.flatten
    res = tr.map { |t| t.resource }.flatten.compact
    res.each do |r|
      resources.delete r
    end
  end

  def add_page_tabs page
    pages << page
    tr = page.tabs.map { |t| t.tab_resources }.flatten
    res = tr.map { |t| t.resource }.flatten.compact
    resources << res
  end

  def delete_page_tabs page
    pages.delete page
    tr =  page.tabs.map { |t| t.tab_resources }.flatten
    res = tr.map { |t| t.resource }.flatten.compact
    res.each do |r|
      resources.delete r
    end
  end

  def add_resource resource
    resources << resource
  end

  def add_tutorial tutorial
    tutorials << tutorial
  end

  def num_modules
    resources.map(&:mod).compact.length
  end

  def published_pages
    pages.select &:published
  end

  def archived_pages
    pages.select &:archived
  end

  def published_guides
    guides.select &:published
  end

  def published_tutorials
    tutorials.select &:published
  end

  def archived_tutorials
    tutorials.select &:archived
  end

  def recent_activity
    recent = lambda { |x| x.updated_at >= 7.days.ago }
    mods = resources.map(&:mod).compact.select &recent
    icaps = pages.select &recent
    srgs = guides.select &recent
    orts = tutorials.select &recent
    recents =  mods[0..5] + icaps[0..5] + srgs[0..5] + orts[0..5]
    recents.sort_by &:updated_at
  end

  def module_tags
    resources.map { |a| a.mod.tag_list if a.mod }.flatten.uniq
  end

  def find_mods_tagged_with tag
    resources.map { |a| a.mod if a.mod and a.mod.tag_list.include? tag }.compact.uniq
  end

  def find_resource id, type
    resources.find_by_mod_id_and_mod_type id, type
  end

  def add_profile rid
    update_attribute :resource_id, rid
  end

  def get_profile
    Resource.exists?(resource_id) ? Resource.find(resource_id).mod : ''
  end

  def contact_resources
    contacts = resources.select { |a| a.mod and a.mod.content_type.in? ["Librarian Profile", "Custom Content", "Course Widget"] }
    contacts.sort_by { |a| a.mod.label.downcase }
  end

  def sort_search_mods sort_by, search_results
    sort,reverse = mod_sort_by_values sort_by
    modules sort, reverse, search_results
  end

  def sort_mods sort_by, list_by = nil
    sort, reverse = 'label', 'false'
    case list_by
    when "global" then (mods =  Resource.global_modules(sort, reverse))
    else  (mods = modules(sort, reverse))
    end
    mods
  end

  def modules s = nil, rev = nil, list = nil
    mods = (list == nil ? resources.collect {|a| a.mod if a and a.mod}.compact : list)
    mods.sort_by { |a| a.label.downcase }.uniq
  end

  def sort_search_guides sort_by, search_results
    sort_guides sort_by
  end

  def sort_guides sort_by
    sorted_guides sort_by, nil, guides
  end

  def sorted_guides sort, reverse, list
    list.sort_by { |a| a.guide_name.downcase }.uniq
  end

  def sort_search_pages sort_by, search_results
    sort_pages sort_by
  end

  def sort_pages sort_by
    sorted_pages sort_by, nil, pages
  end

  def sorted_pages sort, reverse, list
    list.sort_by { |a| a.course_name.downcase }.uniq
  end

  def sort_search_tutorials sort_by, search_results
    sort_tuts sort_by
  end

  def sort_tutorials sort_by
    sorted_tuts my_tutorials
  end

  def sorted_tuts list
    list.sort_by { |a| a.name.downcase }.uniq
  end

  def sort_units sort_by
    units
  end

  def units
    Unit.where created_by: id
  end

  def password
    @password
  end

  def password= pwd
    @password = pwd
    if self.salt.nil? or self.salt.empty?
      self.salt = User.random_string 10
    end
    self.hashed_psswrd = User.encrypt self.password, self.salt
  end

  def set_new_password
    new_password = User.random_string 10
    self.password = new_password
    self.password_confirmation = new_password
    self.save
    UserMailer.forgot_password(self.email, self.password).deliver
  end

  def is_admin
    self.role == 'admin'
  end

  def is_pending
    self.role == 'pending'
  end

  def generate_password
    User.random_string 10
  end

  private

  def self.encrypt password, salt
    Digest::SHA1.hexdigest(password + salt)
  end

  def self.random_string len
    chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    1.upto(len).map { chars[rand(chars.size - 1)] }.join ''
  end
end
