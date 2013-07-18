require 'faker'

FactoryGirl.define do
  factory :subject do
    subject_code { Faker::Lorem.word     }
    subject_name { Faker::Lorem.sentence }
  end
end
