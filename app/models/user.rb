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
#  node_id       :integer
#

require 'digest/sha1'
require 'xmlrpc/client'

class User < ActiveRecord::Base
  has_and_belongs_to_many :guides
  has_and_belongs_to_many :pages
  has_and_belongs_to_many :nodes
  belongs_to :node

  attr_accessor :password_confirmation

  validates :name, length: { in: 2..54 }
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, uniqueness: true
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
      Notifications.add_pending_user(user.email, local.admin_email_from).deliver
      Notifications.notify_admin_about_pending_user(local.admin_email_to, local.admin_email_from, url).deliver
      msg = _ 'An account was created for you.  It is now waiting for administrator approval.'
    rescue Exception => e
      logger.error("Exception in register user: #{e}}" )
      msg = _' Could not send email'
    end
    return msg
  end

  def validate
    errors.add(_ 'Missing password') if hashed_psswrd.blank?
  end

  def self.create_and_add_node id, mod_list, item = nil
    user = find id
    mod_list.each { |mod| user.create_and_add_node mod, item }
  end

  def create_and_add_node node, item = nil
    node.update_attribute :created_by, name
    nodes << node
    item.add_node node unless item.nil?
  end

  def add_page page
    page.created_by = name
    page.node_id = node_id
    page.save
    pages << page
  end

  def add_guide guide
    guide.created_by = name
    guide.node_id = node_id
    guide.save
    guides << guide
  end

  def add_node node
    nodes << node
  end

  def add_guide_tabs guide
    guides << guide
    nodes << guide.tabs.flat_map(&:nodes)
  end

  def delete_guide_tabs guide
    guides.delete guide
    guide.tabs.flat_map(&:nodes).each do |node|
      nodes.delete node
    end
  end

  def add_page_tabs page
    pages << page
    nodes << page.tabs.flat_map(&:nodes)
  end

  def delete_page_tabs page
    pages.delete page
    page.tabs.flat_map(&:nodes).each do |node|
      nodes.delete node
    end
  end

  def num_nodes
    nodes.length
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

  def recent_activity
    recent = -> x { x.updated_at >= 7.days.ago }
    modules = nodes.select &recent
    course_pages = pages.select &recent
    subject_guides = guides.select &recent
    recents = modules[0..5] + course_pages[0..5] + subject_guides[0..5]
    recents.sort_by &:updated_at
  end

  def node_tags
    nodes.flat_map(&:tag_list).uniq
  end

  def find_mods_tagged_with tag
    nodes.select { |a| a.tag_list.include? tag }
  end

  def find_node id
    Node.find id
  end

  def add_profile rid
    update_attribute :node_id, rid
  end

  def get_profile
    node
  end

  def contact_nodes
    nodes.sort_by { |a| a.label.downcase }
  end

  def sort_search_mods sort_by, search_results
    nodes
  end

  def sort_mods sort_by, list_by = nil
    nodes
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
    Notifications.forgot_password(self.email, self.password).deliver
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
