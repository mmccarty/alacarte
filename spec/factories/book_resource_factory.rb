require 'faker'

FactoryGirl.define do
  factory :book_resource do
    module_title { Faker::Lorem.sentence }
  end
end
