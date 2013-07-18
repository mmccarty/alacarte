require 'faker'

FactoryGirl.define do
  factory :master do
    value { Faker::Lorem.sentence }
  end
end
