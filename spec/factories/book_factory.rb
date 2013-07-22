require 'faker'

FactoryGirl.define do
  factory :book do
    url { Faker::Internet.url }
  end
end
