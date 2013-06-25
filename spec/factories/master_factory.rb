require 'faker'

FactoryGirl.define do
  factory :master do |master|
    master.value { Faker::Name.name }
  end
end
