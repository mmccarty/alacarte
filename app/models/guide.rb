# == Schema Information
#
# Table name: guides
#
#  id          :integer          not null, primary key
#  guide_name  :string(255)      not null
#  node_id     :integer
#  updated_at  :datetime
#  created_by  :string(255)      default("")
#  published   :boolean          default(FALSE)
#  description :text
#  relateds    :text
#

class Guide < ActiveRecord::Base
  include ActsAsGuide

  has_and_belongs_to_many :masters

  validates :guide_name, presence: true, uniqueness: true

  def self.published_guides
    self.where(published: true).order(:guide_name).select 'id, guide_name, description'
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

  def related_pages
    subjects.flat_map(&:get_pages).uniq
  end

  def replicate user, options
    new_guide = dup
    num_guides = Guide.where('guide_name like :prefix', prefix: "#{ guide_name}%").count
    new_guide.guide_name = "#{ guide_name }-#{ num_guides + 1}"
    if options == 'copy'
      new_guide.copy_nodes user.id, tabs
    else
      new_guide.copy_tabs tabs
    end

    new_guide.add_tags tag_list
    new_guide.add_master_type masters.map(&:id)
    new_guide.add_related_subjects subjects.map(&:id)
    new_guide
  end
end
