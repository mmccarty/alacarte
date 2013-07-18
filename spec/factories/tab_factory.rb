require 'faker'

FactoryGirl.define do
  factory :tab do
    tab_name  { Faker::Lorem.sentence }
  end
end
