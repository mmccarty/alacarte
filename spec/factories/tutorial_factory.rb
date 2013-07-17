require 'faker'

FactoryGirl.define do
  factory :tutorial do
    name        { Faker::Lorem.sentence }
    course_num  { Faker::Address.building_number }
    section_num { Faker::Address.building_number }
  end
end
