# == Schema Information
#
# Table name: locals
#
#  id                  :integer          not null, primary key
#  banner_url          :string(255)
#  logo_url            :string(255)
#  styles              :string(255)
#  lib_name            :string(255)
#  lib_url             :string(255)
#  univ_name           :string(255)
#  univ_url            :string(255)
#  footer              :text
#  book_search         :text
#  site_search         :text
#  g_search            :text
#  g_results           :text
#  image_map           :text
#  ica_page_title      :string(255)      default("Get Help with a Class")
#  guide_page_title    :string(255)      default("Get Help with a Subject")
#  tutorial_page_title :string(255)      default("Online Research Tutorials")
#  logo_width          :integer
#  logo_height         :integer
#  types               :text
#  guides              :text
#  proxy               :string(255)
#  admin_email_to      :string(255)
#  admin_email_from    :string(255)
#  left_box            :text
#  js_link             :string(255)
#  meta                :text
#  tracking            :text
#  site_search_label   :string(255)
#  book_search_label   :string(255)
#  guide_box           :text
#  right_box           :text
#  enable_search       :boolean          default(TRUE)
#

class Local < ActiveRecord::Base
  serialize :types
  serialize :guides
  before_create :initialize_types

  # Returns a list of derived resource types in a form suitable for a select/option control.
  def mod_types
    MODULES.select { |m| m[1].in? types_list }
  end

  def guides_list
    guides.flatten
  end

  def types_list
    types.flatten
  end

  def initialize_types
    self.guides = %w(pages guides tutorials)
    self.types  = %w(comment miscellaneous database inst lib quiz rss url).map { |s| "#{ s }_resource" }
  end
end
