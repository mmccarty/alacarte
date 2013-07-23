require 'faker'

FactoryGirl.define do
  factory :quiz_resource do
    module_title { Faker::Lorem.sentence }
  end
end