# == Schema Information
#
# Table name: nodes
#
#  id           :integer          not null, primary key
#  module_title :string(255)      default(""), not null
#  label        :string(255)
#  content      :text
#  more_info    :text
#  created_by   :string(255)
#  updated_at   :datetime
#  global       :boolean          default(FALSE)
#  slug         :string(255)
#  published    :boolean          default(FALSE)
#

require 'faker'

FactoryGirl.define do
  factory :node do
    module_title { Faker::Lorem.sentence }
  end
end
