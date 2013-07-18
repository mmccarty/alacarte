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
