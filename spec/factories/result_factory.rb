require 'faker'

FactoryGirl.define do
  factory :result do
    guess { Faker::Lorem.sentence }
  end
end