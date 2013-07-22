require 'faker'

FactoryGirl.define do
  factory :lib_resource do
    module_title { Faker::Lorem.sentence }
  end
end