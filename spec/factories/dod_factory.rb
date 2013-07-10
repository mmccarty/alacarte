require 'faker'

FactoryGirl.define do
  factory :dod do
    title    { Faker::Company.catch_phrase }
    url      { Faker::Internet.url         }
    provider { Faker::Company.name         }
    descr    { Faker::Company.bs           }
  end
end
