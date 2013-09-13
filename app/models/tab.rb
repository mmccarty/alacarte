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
  has_many :tab_nodes, -> { order 'position' }, dependent: :destroy
  has_many :nodes, through: :tab_nodes
  acts_as_list scope: 'tabable_id=#{tabable_id} AND tabable_type=\'#{tabable_type}\''

  validates :tab_name, presence: true
  validates :template, inclusion: { in: [1, 2] }

  def update_users
    if guide.present? and guide.shared?
      guide.update_users
    elsif page.present? and page.shared?
      page.update_users
    end
  end

  def guide
    (tabable_type == 'Guide' && Guide.exists?(tabable_id)) ? Guide.find(tabable_id) : ''
  end

  def page
    (tabable_type == 'Page'  && Page.exists?(tabable_id))  ? Page.find(tabable_id)  : ''
  end

  def num_columns
    self.template
  end

  def toggle_columns
    update_attribute :template, (template != 2) ? 2 : 1
  end

  def sorted_nodes
    tab_nodes.map &:node
  end

  def reorder_nodes resource_ids
    resource_ids.each_with_index do |id, index|
      tn = tab_nodes.select { |tn| tn.node.id == id }.first
      tn.set_list_position index+1 if tn
    end
  end

  def left_nodes
    tab_nodes.select { |t| t.position.odd? }.map &:node
  end

  def right_nodes
    tab_nodes.select{ |t| t.position.even? }.map &:node
  end

  def add_tags tags
    self.tag_list = tags
    self.save
  end

  def recent_nodes
    nodes.sort_by &:updated_at
  end

  def find_node id
    Node.find id
  end

  def add_node id
    nodes << Node.find(id)
    update_users
  end

  def update_nodes resrs
    resrs.each do |value|
      id = value.gsub /[^0-9]/, ''
      node = Node.find id
      node.create_slug if node.slug.blank?
      nodes << node
    end
  end
end
