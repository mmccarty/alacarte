require 'faker'

FactoryGirl.define do
  factory :inst_resource do
    module_title { Faker::Lorem.sentence }
  end
end
