require 'faker'

FactoryGirl.define do
  factory :comment_resource do
    module_title { Faker::Lorem.sentence }
  end
end
