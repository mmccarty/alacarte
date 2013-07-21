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
  include HasModules

  belongs_to :tabable, polymorphic: true
  has_many :tab_resources, order: :position, dependent: :destroy
  has_many :resources, through: :tab_resources
  acts_as_list scope: 'tabable_id=#{tabable_id} AND tabable_type=\'#{tabable_type}\''

  validates :tab_name, presence: true
  validates :template, inclusion: { in: [1, 2] }

  def update_users
    if guide != "" and guide.shared?
      guide.update_users
    elsif page != "" and page.shared?
      page.update_users
    end
  end

  def guide
    (tabable_type == "Guide" && Guide.exists?(tabable_id)) ? Guide.find(tabable_id) : ""
  end

  def page
    (tabable_type == "Page"  && Page.exists?(tabable_id))  ? Page.find(tabable_id)  : ""
  end

  def num_columns
    self.template
  end

  def toggle_columns
    update_attribute :template, (template != 2) ? 2 : 1
  end

  def sorted_modules
    tab_resources.map { |t| t.resource.mod if t and t.resource }.compact
  end

  def left_resources
    tab_resources.select { |t| t.position.odd? and t.resource and t.resource.mod }.flatten.compact
  end

  def right_resources
    tab_resources.select{ |t| t.position.even? and t.resource and t.resource.mod }.flatten.compact
  end

  def left_modules
    left_resources.map { |r| r.resource.mod }
  end

  def right_modules
    right_resources.map { |r| r.resource.mod }
  end
end
