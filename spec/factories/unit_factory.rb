require 'faker'

FactoryGirl.define do
  factory :unit do
    title { Faker::Lorem.sentence }
  end
end
