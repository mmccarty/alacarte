# == Schema Information
#
# Table name: pages
#
#  id          :integer          not null, primary key
#  published   :boolean          default(FALSE)
#  sect_num    :string(255)
#  course_name :string(255)      not null
#  term        :string(255)      default("")
#  year        :string(255)      default("")
#  campus      :string(255)      default("")
#  course_num  :string(255)
#  description :text
#  updated_at  :datetime
#  created_on  :date
#  archived    :boolean          default(FALSE)
#  node_id     :integer
#  created_by  :string(255)
#  relateds    :text
#

require 'faker'

FactoryGirl.define do
  factory :page do
    course_name { Faker::Lorem.sentence }
    course_num  { Faker::Address.building_number }
    sect_num    { Faker::Address.building_number }

    after :build do |page|
      page.subjects << build(:subject)
    end

    factory :published_page do
      published true
    end
  end
end
