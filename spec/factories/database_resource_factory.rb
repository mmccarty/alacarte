require 'faker'

FactoryGirl.define do
  factory :database_resource do
    module_title { Faker::Lorem.sentence }
  end
end