require 'faker'

FactoryGirl.define do
  factory :question do
    question { Faker::Lorem.sentence }
    points 1
  end
end