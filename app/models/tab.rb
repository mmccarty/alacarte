# == Schema Information
#
# Table name: tabs
#
#  id           :integer          not null, primary key
#  tab_name     :string(255)
#  updated_at   :datetime
#  position     :integer
#  template     :integer          default(2)
#  tabable_id   :integer
#  tabable_type :string(255)
#

class Tab < ActiveRecord::Base
  belongs_to :tabable, polymorphic: true
  has_many :tab_resources, order: :position, dependent: :destroy
  has_many :resources, through: :tab_resources
  acts_as_list scope: 'tabable_id=#{tabable_id} AND tabable_type=\'#{tabable_type}\''

  validates :tab_name, presence: true

  def add_module(id, type)
    resource = Resource.find_by_mod_id_and_mod_type(id,type)
    if resource
      resources << resource
      update_users
    end
  end

  def update_resource(resrs)
    resrs.each do |value|
      id = value.gsub(/[^0-9]/, '')
      type = value.gsub(/[^A-Za-z]/, '')
      resource = Resource.find_by_mod_id_and_mod_type(id,type)
      resources << resource
    end
  end

  def add_resource(resource)
    resources << resource
    update_users
  end

  def update_users
    if guide != "" and guide.shared?
      guide.update_users
    elsif page != "" and page.shared?
      page.update_users
    end
  end

  def guide
    (tabable_type == "Guide" and Guide.exists?(tabable_id))  ? Guide.find(tabable_id) : ""
  end

  def page
    (tabable_type == "Page" and Page.exists?(tabable_id))  ? Page.find(tabable_id) : ""
  end

  def find_resource(id, type)
    resources.find_by_mod_id_and_mod_type(id, type)
  end

  def modules
    resources.collect {|a| a.mod if a}.compact
  end

  def recent_modules
    sortable = "updated_at"
    m = resources.collect{ |a| a.mod}.compact
    m.sort!{|a,b|  a.send(sortable) <=> b.send(sortable)}
  end

  def sorted_modules
    tab_resources.collect{|t| t.resource.mod if t and t.resource}.compact
  end

  def left_resources
    odd = []
    odd << tab_resources.select{|t|t.position.odd? and t.resource and t.resource.mod}
    odd.flatten.compact
  end

  def right_resources
    even = []
    even << tab_resources.select{|t|t.position.even? and t.resource and t.resource.mod}
    even.flatten.compact
  end

  def left_modules
    odd = []
    tr = tab_resources.select{|t|t.position.odd?}
    odd << tr.collect{|t| t.resource.mod if t.resource}
    odd.flatten.compact
  end

  def right_modules
    even = []
    tr = tab_resources.select{|t|t.position.even?}
    even << tr.collect{|t| t.resource.mod if t.resource}
    even.flatten.compact
  end
end
