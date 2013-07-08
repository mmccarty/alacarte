require 'faker'

FactoryGirl.define do
  factory :master do
    value { Faker::Lorem.words }
  end
end
