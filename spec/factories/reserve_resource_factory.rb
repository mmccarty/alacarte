require 'faker'

FactoryGirl.define do
  factory :reserve_resource do
    module_title { Faker::Lorem.word }
  end
end